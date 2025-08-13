require 'rails_helper'

RSpec.describe OrganizationsController, type: :controller do
  let(:admin) { create(:user, role: 'admin') }
  let(:user) { create(:user, role: 'participant') }
  let(:valid_attributes) { attributes_for(:organization) }
  let(:invalid_attributes) { { name: '' } }
  let(:organization) { create(:organization) }

  context 'as an admin user' do
    before { sign_in admin }

    describe 'GET #index' do
      it 'returns a success response' do
        get :index
        expect(response).to be_successful
      end
    end

    describe 'GET #show' do
      it 'returns a success response' do
        get :show, params: { id: organization.to_param }
        expect(response).to be_successful
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        get :new
        expect(response).to be_successful
      end
    end

    describe 'GET #edit' do
      it 'returns a success response' do
        get :edit, params: { id: organization.to_param }
        expect(response).to be_successful
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new Organization' do
          expect {
            post :create, params: { organization: valid_attributes }
          }.to change(Organization, :count).by(1)
        end

        it 'redirects to the created organization' do
          post :create, params: { organization: valid_attributes }
          expect(response).to redirect_to(Organization.last)
        end
      end

      context 'with invalid params' do
        it 'returns a success response (i.e. to display the new template)' do
          post :create, params: { organization: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        let(:new_attributes) { { name: 'Updated Name' } }

        it 'updates the requested organization' do
          put :update, params: { id: organization.to_param, organization: new_attributes }
          organization.reload
          expect(organization.name).to eq('Updated Name')
        end

        it 'redirects to the organization' do
          put :update, params: { id: organization.to_param, organization: valid_attributes }
          expect(response).to redirect_to(organization)
        end
      end

      context 'with invalid params' do
        it 'returns a success response (i.e. to display the edit template)' do
          put :update, params: { id: organization.to_param, organization: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe 'DELETE #destroy' do
      let!(:organization_to_delete) { create(:organization) }

      it 'destroys the requested organization' do
        expect {
          delete :destroy, params: { id: organization_to_delete.to_param }
        }.to change(Organization, :count).by(-1)
      end

      it 'redirects to the organizations list' do
        delete :destroy, params: { id: organization_to_delete.to_param }
        expect(response).to redirect_to(organizations_url)
      end
    end
  end

  context 'as a non-admin user' do
    before { sign_in user }

    describe 'GET #index' do
      it 'redirects to root path' do
        get :index
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('Access denied. Admin privileges required.')
      end
    end

    [ :show, :new, :edit, :create, :update, :destroy ].each do |action|
      describe "accessing ##{action}" do
        it 'redirects to root path' do
          case action
          when :show, :edit, :update, :destroy
            get action, params: { id: organization.to_param }
          when :create
            post action, params: { organization: valid_attributes }
          when :new
            get action
          end
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq('Access denied. Admin privileges required.')
        end
      end
    end
  end

  context 'as a guest' do
    describe 'GET #index' do
      it 'redirects to login page' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    [ :show, :new, :edit, :create, :update, :destroy ].each do |action|
      describe "accessing ##{action}" do
        it 'redirects to login page' do
          case action
          when :show, :edit, :update, :destroy
            get action, params: { id: organization.to_param }
          when :create
            post action, params: { organization: valid_attributes }
          when :new
            get action
          end
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end
end
