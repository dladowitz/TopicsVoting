# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Organizations", type: :request do
  let(:site_admin) { create(:user, :admin) }
  let(:org_admin) { create(:user) }
  let(:regular_user) { create(:user) }
  let(:valid_attributes) { attributes_for(:organization) }
  let(:invalid_attributes) { { name: '' } }
  let(:organization) { create(:organization) }

  context 'as a site admin' do
    before(:each) { sign_in site_admin }

    describe 'GET /organizations' do
      it 'returns a success response' do
        get organizations_path
        expect(response).to be_successful
      end
    end

    describe 'GET /organizations/:id' do
      it 'returns a success response' do
        get organization_path(organization)
        expect(response).to be_successful
      end
    end

    describe 'GET /organizations/:id/settings' do
      it 'returns a success response' do
        get settings_organization_path(organization)
        expect(response).to be_successful
      end

      it 'finds a user by email' do
        user = create(:user)
        get settings_organization_path(organization, email: user.email)
        expect(response).to be_successful
        expect(assigns(:found_user)).to eq(user)
      end

      it 'returns nil for non-existent user' do
        get settings_organization_path(organization, email: 'nonexistent@example.com')
        expect(response).to be_successful
        expect(assigns(:found_user)).to be_nil
      end
    end

    describe 'GET /organizations/new' do
      it 'returns a success response' do
        get new_organization_path
        expect(response).to be_successful
      end
    end

    describe 'GET /organizations/:id/edit' do
      it 'returns a success response' do
        get edit_organization_path(organization)
        expect(response).to be_successful
      end
    end

    describe 'POST /organizations' do
      context 'with valid params' do
        it 'creates a new Organization' do
          expect {
            post organizations_path, params: { organization: valid_attributes }
          }.to change(Organization, :count).by(1)
        end

        it 'redirects to the created organization' do
          post organizations_path, params: { organization: valid_attributes }
          expect(response).to redirect_to(Organization.last)
        end

        it 'creates an organization with bolt12_invoice' do
          bolt12_invoice = "lno1zrxq8pjw7qjlm68mtp7e.........................................."
          post organizations_path, params: {
            organization: valid_attributes.merge(bolt12_invoice: bolt12_invoice)
          }
          expect(response).to redirect_to(Organization.last)
          expect(Organization.last.bolt12_invoice).to eq(bolt12_invoice)
        end

        it 'creates an organization with a long bolt12_invoice' do
          long_bolt12_invoice = "lno1zrxq8pjw7qjlm68mtp7e" + "a" * 1000
          post organizations_path, params: {
            organization: valid_attributes.merge(bolt12_invoice: long_bolt12_invoice)
          }
          expect(response).to redirect_to(Organization.last)
          expect(Organization.last.bolt12_invoice).to eq(long_bolt12_invoice)
        end

        it 'creates an organization without bolt12_invoice' do
          post organizations_path, params: { organization: valid_attributes }
          expect(response).to redirect_to(Organization.last)
          expect(Organization.last.bolt12_invoice).to be_nil
        end
      end

      context 'with invalid params' do
        it 'returns a success response (i.e. to display the new template)' do
          post organizations_path, params: { organization: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe 'PUT /organizations/:id' do
      context 'with valid params' do
        let(:new_attributes) { { name: 'Updated Name' } }

        it 'updates the requested organization' do
          put organization_path(organization), params: { organization: new_attributes }
          organization.reload
          expect(organization.name).to eq('Updated Name')
        end

        it 'redirects to the organization' do
          put organization_path(organization), params: { organization: valid_attributes }
          expect(response).to redirect_to(organization)
        end

        it 'updates bolt12_invoice field' do
          bolt12_invoice = "lno1zrxq8pjw7qjlm68mtp7e.........................................."
          put organization_path(organization), params: {
            organization: { bolt12_invoice: bolt12_invoice }
          }
          organization.reload
          expect(organization.bolt12_invoice).to eq(bolt12_invoice)
        end

        it 'updates bolt12_invoice to a long value' do
          long_bolt12_invoice = "lno1zrxq8pjw7qjlm68mtp7e" + "b" * 1500
          put organization_path(organization), params: {
            organization: { bolt12_invoice: long_bolt12_invoice }
          }
          organization.reload
          expect(organization.bolt12_invoice).to eq(long_bolt12_invoice)
        end

        it 'clears bolt12_invoice field when set to empty string' do
          # First set a bolt12_invoice
          organization.update!(bolt12_invoice: "lno1zrxq8pjw7qjlm68mtp7e..........................................")

          # Then clear it
          put organization_path(organization), params: {
            organization: { bolt12_invoice: "" }
          }
          organization.reload
          expect(organization.bolt12_invoice).to eq("")
        end

        it 'updates multiple fields including bolt12_invoice' do
          bolt12_invoice = "lno1zrxq8pjw7qjlm68mtp7e.........................................."
          put organization_path(organization), params: {
            organization: {
              name: "Updated Organization",
              city: "New York",
              bolt12_invoice: bolt12_invoice
            }
          }
          organization.reload
          expect(organization.name).to eq("Updated Organization")
          expect(organization.city).to eq("New York")
          expect(organization.bolt12_invoice).to eq(bolt12_invoice)
        end
      end

      context 'with invalid params' do
        it 'returns a success response (i.e. to display the edit template)' do
          put organization_path(organization), params: { organization: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe 'DELETE /organizations/:id' do
      let!(:organization_to_delete) { create(:organization) }

      it 'destroys the requested organization' do
        expect {
          delete organization_path(organization_to_delete)
        }.to change(Organization, :count).by(-1)
      end

      it 'redirects to the organizations list' do
        delete organization_path(organization_to_delete)
        expect(response).to redirect_to(organizations_url)
      end
    end
  end

  context 'as an organization admin' do
    before(:each) do
      sign_in org_admin
      create(:organization_role, organization: organization, user: org_admin, role: 'admin')
    end

    describe 'GET /organizations' do
      it 'returns a success response' do
        get organizations_path
        expect(response).to be_successful
      end
    end

    describe 'GET /organizations/:id' do
      it 'returns a success response' do
        get organization_path(organization)
        expect(response).to be_successful
      end
    end

    describe 'GET /organizations/:id/settings' do
      it 'returns a success response' do
        get settings_organization_path(organization)
        expect(response).to be_successful
      end

      it 'finds a user by email' do
        user = create(:user)
        get settings_organization_path(organization, email: user.email)
        expect(response).to be_successful
        expect(assigns(:found_user)).to eq(user)
      end

      it 'returns nil for non-existent user' do
        get settings_organization_path(organization, email: 'nonexistent@example.com')
        expect(response).to be_successful
        expect(assigns(:found_user)).to be_nil
      end
    end

    describe 'accessing other actions' do
      [ :new, :edit, :create, :update, :destroy ].each do |action|
        it "redirects to root path for #{action}" do
          case action
          when :edit
            get edit_organization_path(organization)
          when :update
            put organization_path(organization), params: { organization: valid_attributes }
          when :destroy
            delete organization_path(organization)
          when :create
            post organizations_path, params: { organization: valid_attributes }
          when :new
            get new_organization_path
          end
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq('You are not authorized to access this page.')
        end
      end
    end
  end

  context 'as a regular user' do
    before(:each) { sign_in regular_user }

    describe 'GET /organizations' do
      it 'returns a success response' do
        get organizations_path
        expect(response).to be_successful
      end
    end

    describe 'GET /organizations/:id' do
      it 'returns a success response' do
        get organization_path(organization)
        expect(response).to be_successful
      end
    end

    describe 'GET /organizations/:id/settings' do
      it 'redirects to root path' do
        get settings_organization_path(organization)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You are not authorized to access this page.')
      end

      it 'redirects to root path when searching users' do
        get settings_organization_path(organization, email: 'test@example.com')
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq('You are not authorized to access this page.')
      end
    end

    [ :new, :edit, :create, :update, :destroy ].each do |action|
      describe "accessing ##{action}" do
        it 'redirects to root path' do
          case action
          when :edit
            get edit_organization_path(organization)
          when :update
            put organization_path(organization), params: { organization: valid_attributes }
          when :destroy
            delete organization_path(organization)
          when :create
            post organizations_path, params: { organization: valid_attributes }
          when :new
            get new_organization_path
          end
          expect(response).to redirect_to(root_path)
          expect(flash[:alert]).to eq('You are not authorized to access this page.')
        end
      end
    end
  end

  context 'as a guest' do
    describe 'GET /organizations' do
      it 'returns a success response' do
        get organizations_path
        expect(response).to be_successful
      end
    end

    describe 'GET /organizations/:id' do
      it 'returns a success response' do
        get organization_path(organization)
        expect(response).to be_successful
      end
    end

    [ :new, :edit, :create, :update, :destroy, :settings ].each do |action|
      describe "accessing ##{action}" do
        it 'redirects to login page' do
          case action
          when :edit
            get edit_organization_path(organization)
          when :update
            put organization_path(organization), params: { organization: valid_attributes }
          when :destroy
            delete organization_path(organization)
          when :settings
            get settings_organization_path(organization)
          when :create
            post organizations_path, params: { organization: valid_attributes }
          when :new
            get new_organization_path
          end
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end
end
