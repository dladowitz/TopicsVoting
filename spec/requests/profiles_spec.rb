require 'rails_helper'

RSpec.describe 'Profiles', type: :request do
  describe 'GET /profile' do
    context 'when signed in' do
      let(:user) { create(:user) }

      it 'returns success and renders the page' do
        sign_in user
        get profile_path
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:show)
        expect(response.body).to include(user.email)
        expect(response.body).to include('User')
      end
    end

    context 'when not signed in' do
      it 'redirects to the login page' do
        get profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
