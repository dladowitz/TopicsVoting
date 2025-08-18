require 'rails_helper'

RSpec.describe "User registration", type: :request do
  include Devise::Test::IntegrationHelpers
  describe "POST /users" do
    it "creates a new user" do
      user_params = {
        user: {
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      post user_registration_path, params: user_params
      expect(response).to have_http_status(:see_other)
      expect(User.last.email).to eq("test@example.com")
      expect(User.last).not_to be_admin
    end
  end
end
