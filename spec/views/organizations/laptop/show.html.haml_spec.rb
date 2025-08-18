# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "organizations/laptop/show", type: :view do
  let(:organization) { create(:organization) }
  let(:site_admin) { create(:user, :admin) }
  let(:org_admin) { create(:user) }
  let(:regular_user) { create(:user) }

  before do
    create(:organization_role, organization: organization, user: org_admin, role: 'admin')
    assign(:organization, organization)
    assign(:active_tab, 'overview')
  end

  context "when user is a site admin" do
    before do
      allow(view).to receive(:current_user).and_return(site_admin)
      allow(view).to receive(:can?).with(:settings, organization).and_return(true)
      render
    end

    it "shows the settings tab" do
      expect(rendered).to have_link('Settings', href: settings_organization_path(organization))
    end
  end

  context "when user is an organization admin" do
    before do
      allow(view).to receive(:current_user).and_return(org_admin)
      allow(view).to receive(:can?).with(:settings, organization).and_return(true)
      render
    end

    it "shows the settings tab" do
      expect(rendered).to have_link('Settings', href: settings_organization_path(organization))
    end
  end

  context "when user is a regular user" do
    before do
      allow(view).to receive(:current_user).and_return(regular_user)
      allow(view).to receive(:can?).with(:settings, organization).and_return(false)
      render
    end

    it "does not show the settings tab" do
      expect(rendered).not_to have_link('Settings')
    end
  end
end
