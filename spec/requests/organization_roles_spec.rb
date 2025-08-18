# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OrganizationRoles", type: :request do
  let(:organization) { create(:organization) }
  let(:site_admin) { create(:user, :admin) }
  let(:org_admin) { create(:user) }
  let(:regular_user) { create(:user) }
  let(:target_user) { create(:user) }

  before(:each) do
    create(:organization_role, organization: organization, user: org_admin, role: "admin")
  end

  describe "POST /organizations/:organization_id/roles" do
    let(:valid_params) do
      {
        email: target_user.email,
        role: "moderator"
      }
    end

    context "as a site admin" do
      before(:each) { sign_in site_admin }

      it "creates a new organization role" do
        expect {
          post organization_organization_roles_path(organization), params: valid_params
        }.to change(OrganizationRole, :count).by(1)
        expect(response).to redirect_to(settings_organization_path(organization))
        expect(flash[:notice]).to eq("Role was successfully assigned.")
      end

      it "handles invalid user email" do
        expect {
          post organization_organization_roles_path(organization), params: valid_params.merge(email: "nonexistent@example.com")
        }.not_to change(OrganizationRole, :count)
        expect(response).to redirect_to(settings_organization_path(organization))
        expect(flash[:alert]).to eq("User not found.")
      end

      it "handles invalid role" do
        expect {
          post organization_organization_roles_path(organization), params: valid_params.merge(role: "invalid")
        }.not_to change(OrganizationRole, :count)
        expect(response).to redirect_to(settings_organization_path(organization))
        expect(flash[:alert]).to eq("Role is not included in the list")
      end

      it "handles duplicate role assignment" do
        create(:organization_role, organization: organization, user: target_user, role: "moderator")
        expect {
          post organization_organization_roles_path(organization), params: valid_params
        }.not_to change(OrganizationRole, :count)
        expect(response).to redirect_to(settings_organization_path(organization))
        expect(flash[:alert]).to eq("User has already been taken")
      end
    end

    context "as an organization admin" do
      before(:each) { sign_in org_admin }

      it "creates a new organization role" do
        expect {
          post organization_organization_roles_path(organization), params: valid_params
        }.to change(OrganizationRole, :count).by(1)
        expect(response).to redirect_to(settings_organization_path(organization))
        expect(flash[:notice]).to eq("Role was successfully assigned.")
      end

      it "handles invalid user email" do
        expect {
          post organization_organization_roles_path(organization), params: valid_params.merge(email: "nonexistent@example.com")
        }.not_to change(OrganizationRole, :count)
        expect(response).to redirect_to(settings_organization_path(organization))
        expect(flash[:alert]).to eq("User not found.")
      end

      it "handles invalid role" do
        expect {
          post organization_organization_roles_path(organization), params: valid_params.merge(role: "invalid")
        }.not_to change(OrganizationRole, :count)
        expect(response).to redirect_to(settings_organization_path(organization))
        expect(flash[:alert]).to eq("Role is not included in the list")
      end

      it "handles duplicate role assignment" do
        create(:organization_role, organization: organization, user: target_user, role: "moderator")
        expect {
          post organization_organization_roles_path(organization), params: valid_params
        }.not_to change(OrganizationRole, :count)
        expect(response).to redirect_to(settings_organization_path(organization))
        expect(flash[:alert]).to eq("User has already been taken")
      end
    end

    context "as a regular user" do
      before(:each) { sign_in regular_user }

      it "does not create a new organization role" do
        expect {
          post organization_organization_roles_path(organization), params: valid_params
        }.not_to change(OrganizationRole, :count)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to access this page.")
      end
    end
  end

  describe "DELETE /organizations/:organization_id/roles/:id" do
    let!(:role_to_delete) { create(:organization_role, organization: organization, user: target_user, role: "moderator") }

    context "as a site admin" do
      before(:each) { sign_in site_admin }

      it "deletes the organization role" do
        expect {
          delete organization_organization_role_path(organization, target_user, role: "moderator")
        }.to change(OrganizationRole, :count).by(-1)
        expect(response).to redirect_to(settings_organization_path(organization))
        expect(flash[:notice]).to eq("Role was successfully removed.")
      end

      it "handles non-existent role" do
        delete organization_organization_role_path(organization, target_user, role: "admin")
        expect(response).to have_http_status(:not_found)
      end
    end

    context "as an organization admin" do
      before(:each) { sign_in org_admin }

      it "deletes the organization role" do
        expect {
          delete organization_organization_role_path(organization, target_user, role: "moderator")
        }.to change(OrganizationRole, :count).by(-1)
        expect(response).to redirect_to(settings_organization_path(organization))
        expect(flash[:notice]).to eq("Role was successfully removed.")
      end

      it "handles non-existent role" do
        delete organization_organization_role_path(organization, target_user, role: "admin")
        expect(response).to have_http_status(:not_found)
      end
    end

    context "as a regular user" do
      before(:each) { sign_in regular_user }

      it "does not delete the organization role" do
        expect {
          delete organization_organization_role_path(organization, target_user, role: "moderator")
        }.not_to change(OrganizationRole, :count)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to access this page.")
      end
    end
  end
end
