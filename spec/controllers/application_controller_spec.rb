require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  include RSpec::Mocks::ExampleMethods
  # Create a test controller that inherits from ApplicationController
  controller do
    def index
      render plain: 'test'
    end

    def test_disable_admin
      disable_admin_mode
      render plain: 'disabled'
    end
  end

  # Configure routes for our test controller
  before do
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get 'index' => 'anonymous#index'
      get 'test_disable_admin' => 'anonymous#test_disable_admin'
    end
  end

  describe '#set_admin_mode' do
    context 'when mode=admin parameter is present' do
      it 'enables admin mode' do
        get :index, params: { mode: 'admin' }
        expect(cookies[:admin_mode]).to eq('true')
        expect(assigns(:admin_mode)).to be true
      end

      it 'persists admin mode across requests' do
        get :index, params: { mode: 'admin' }
        get :index # Second request without mode parameter
        expect(cookies[:admin_mode]).to eq('true')
        expect(assigns(:admin_mode)).to be true
      end
    end

    context 'when mode parameter is not admin' do
      it 'does not enable admin mode' do
        get :index, params: { mode: 'not_admin' }
        expect(cookies[:admin_mode]).to be_nil
        expect(assigns(:admin_mode)).to be false
      end
    end

    context 'when mode parameter is not present' do
      it 'does not enable admin mode' do
        get :index
        expect(cookies[:admin_mode]).to be_nil
        expect(assigns(:admin_mode)).to be false
      end
    end

    context 'when admin mode was previously enabled' do
      before do
        cookies[:admin_mode] = 'true'
      end

      it 'maintains admin mode without mode parameter' do
        get :index
        expect(assigns(:admin_mode)).to be true
      end
    end
  end

  describe '#disable_admin_mode' do
    it 'disables admin mode' do
      cookies[:admin_mode] = 'true'
      get :test_disable_admin
      expect(cookies[:admin_mode]).to be_nil
      expect(assigns(:admin_mode)).to be false
    end

    it 'persists disabled state' do
      cookies[:admin_mode] = 'true'
      get :test_disable_admin
      expect(assigns(:admin_mode)).to be false
      expect(cookies[:admin_mode]).to be_nil
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
