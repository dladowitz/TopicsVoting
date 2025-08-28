require 'rails_helper'

RSpec.describe "socratic_seminars/laptop/edit", type: :view do
  let(:organization) { create(:organization) }
  let(:socratic_seminar) { create(:socratic_seminar, organization: organization) }

  before do
    assign(:socratic_seminar, socratic_seminar)
    assign(:sections, [])
    allow(view).to receive(:can?).and_return(false)
  end

  context "when user can manage the seminar" do
    before do
      allow(view).to receive(:can?).with(:manage, socratic_seminar).and_return(true)
      render
    end

    it "shows topic management controls" do
      expect(rendered).to have_link("Import Topics")
      expect(rendered).to have_button("Delete Topics")
    end

    it "includes the delete confirmation modal" do
      expect(rendered).to have_css("#deleteSectionsModal")
      expect(rendered).to have_content("Warning: You are deleting ALL Sections & Topics")
      expect(rendered).to have_button("Confirm & Delete")
      expect(rendered).to have_button("Cancel")
    end
  end

  context "when user cannot manage the seminar" do
    before do
      allow(view).to receive(:can?).with(:manage, socratic_seminar).and_return(false)
      render
    end

    it "does not show topic management controls" do
      expect(rendered).not_to have_link("Import Topics")
      expect(rendered).not_to have_button("Delete Topics")
    end
  end
end
