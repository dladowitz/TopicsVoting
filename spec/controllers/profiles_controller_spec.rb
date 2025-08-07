require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  describe 'GET #show' do
    context 'when user is signed in' do
      let(:user) { create(:user) }

      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'responds successfully' do
        get :show
        expect(response).to be_successful
      end

      it 'renders the show template' do
        get :show
        expect(response).to render_template(:show)
      end
    end

    context 'when user is not signed in' do
      it 'redirects to the sign in page' do
        get :show
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
