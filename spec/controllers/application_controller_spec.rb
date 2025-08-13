require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  include RSpec::Mocks::ExampleMethods
  # Create a test controller that inherits from ApplicationController
  controller do
    def index
      render plain: 'test'
    end
  end

  # Configure routes for our test controller
  before do
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get 'index' => 'anonymous#index'
    end
  end


  describe "Devise configuration" do
    controller do
      def test_action
        render plain: "ok"
      end
    end

    before do
      @routes.draw do
        get "test_action" => "anonymous#test_action"
      end
    end

    it "has before_action for devise parameters" do
      filters = controller.class._process_action_callbacks.select { |cb| cb.kind == :before }.map(&:filter)
      expect(filters).to include(:configure_permitted_parameters)
    end

    it "defines configure_permitted_parameters as protected" do
      expect(controller.protected_methods).to include(:configure_permitted_parameters)
    end
  end

  describe "CanCanCan error handling" do
    controller do
      def restricted_action
        raise CanCan::AccessDenied.new("Not authorized!")
      end
    end

    before do
      @routes.draw do
        get "restricted_action" => "anonymous#restricted_action"
      end
    end

    context "with HTML request" do
      it "redirects to root with alert message" do
        get :restricted_action
        expect(response).to redirect_to("/")
        expect(flash[:alert]).to eq("Not authorized!")
      end
    end

    context "with JSON request" do
      it "returns forbidden status with error message" do
        get :restricted_action, format: :json
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)).to eq({ "error" => "Not authorized!" })
      end
    end
  end
end
