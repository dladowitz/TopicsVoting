# frozen_string_literal: true

require "rails_helper"

RSpec.describe "sections/laptop/new", type: :view do
  let(:organization) { create(:organization) }
  let(:socratic_seminar) { create(:socratic_seminar, organization: organization) }
  let(:section) { build(:section, socratic_seminar: socratic_seminar) }

  before do
    assign(:socratic_seminar, socratic_seminar)
    assign(:section, section)
    render
  end

  it "renders new section form" do
    assert_select "form[action=?][method=?]", socratic_seminar_sections_path(socratic_seminar), "post" do
      assert_select "input[name=?]", "section[name]"
    end
  end

  it "renders create button" do
    expect(rendered).to have_button("Create Section")
  end

  it "renders cancel link" do
    expect(rendered).to have_link("Cancel", href: edit_socratic_seminar_path(socratic_seminar))
  end
end
