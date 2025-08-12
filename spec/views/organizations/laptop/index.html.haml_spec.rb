require 'rails_helper'

RSpec.describe "organizations/laptop/index", type: :view do
  let(:organization) { create(:organization) }
  let(:admin_user) { create(:user, role: 'admin') }
  let(:regular_user) { create(:user, role: 'participant') }

  before do
    assign(:organizations, [ organization ])
  end

  context "when user is admin" do
    before do
      allow(view).to receive(:current_user).and_return(admin_user)
      render
    end

    it "displays the new organization button" do
      expect(rendered).to have_link('New Organization', href: new_organization_path)
    end

    it "displays organization details" do
      expect(rendered).to have_content(organization.name)
      expect(rendered).to have_content(organization.city)
      expect(rendered).to have_content(organization.country)
      expect(rendered).to have_link(organization.website, href: organization.website) if organization.website.present?
    end
  end

  context "when user is not admin" do
    before do
      allow(view).to receive(:current_user).and_return(regular_user)
      render
    end

    it "does not display the new organization button" do
      expect(rendered).not_to have_link('New Organization')
    end

    it "displays organization details" do
      expect(rendered).to have_content(organization.name)
      expect(rendered).to have_content(organization.city)
      expect(rendered).to have_content(organization.country)
      expect(rendered).to have_link(organization.website, href: organization.website) if organization.website.present?
    end
  end
end
