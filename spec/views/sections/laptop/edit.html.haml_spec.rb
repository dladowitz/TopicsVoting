# frozen_string_literal: true

require "rails_helper"

RSpec.describe "sections/laptop/edit", type: :view do
  let(:organization) { create(:organization) }
  let(:socratic_seminar) { create(:socratic_seminar, organization: organization) }
  let(:section) { create(:section, socratic_seminar: socratic_seminar, name: "Test Section") }

  before do
    assign(:socratic_seminar, socratic_seminar)
    assign(:section, section)
    render
  end

  it "renders the edit section form" do
    assert_select "form[action=?][method=?]", socratic_seminar_section_path(socratic_seminar, section), "post" do
      assert_select "input[name=?]", "section[name]"
    end
  end

  it "displays the section name" do
    expect(rendered).to have_field("section[name]", with: "Test Section")
  end

  it "renders update button" do
    expect(rendered).to have_button("Update Section")
  end

  it "renders cancel link" do
    expect(rendered).to have_link("Cancel", href: edit_socratic_seminar_path(socratic_seminar))
  end

  it "renders delete button" do
    expect(rendered).to have_button("Delete")
  end

  context "when section has topics" do
    before do
      create_list(:topic, 2, section: section)
      render
    end

    it "includes topic count in delete confirmation" do
      expect(rendered).to have_selector("form[data-turbo-confirm*='2 topics']")
    end
  end
end
