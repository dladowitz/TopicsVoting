require 'rails_helper'

RSpec.describe "User registration", type: :request do
  include Devise::Test::IntegrationHelpers
  describe "POST /users" do
    it "allows registration with role parameter" do
      user_params = {
        user: {
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "admin"
        }
      }

      post user_registration_path, params: user_params
      expect(response).to have_http_status(:see_other)
      expect(User.last.role).to eq("admin")
      expect(User.last.email).to eq("test@example.com")
    end

    it "allows updating role for existing user" do
      user = create(:user, password: "password123")
      sign_in user

      put user_registration_path, params: {
        user: {
          email: user.email,
          role: "moderator",
          current_password: "password123"
        }
      }

      expect(response).to have_http_status(:see_other)
      user.reload
      expect(user.role).to eq("moderator")
    end
  end
end
