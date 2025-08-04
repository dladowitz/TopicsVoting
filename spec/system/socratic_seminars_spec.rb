require 'rails_helper'

RSpec.describe "Socratic Seminars", type: :system do
  let(:socratic_seminar) { create(:socratic_seminar) }

  before do
    driven_by(:selenium_chrome_headless)
  end

  it "visiting the index" do
    visit socratic_seminars_path
    expect(page).to have_selector("h1", text: "Socratic seminars")
  end

  it "creates a socratic seminar" do
    visit socratic_seminars_path
    click_on "New socratic seminar"

    fill_in "Date", with: socratic_seminar.date
    fill_in "Seminar number", with: socratic_seminar.seminar_number
    click_on "Create Socratic seminar"

    expect(page).to have_text("Socratic seminar was successfully created")
    click_on "Back"
  end

  it "updates a Socratic seminar" do
    visit socratic_seminar_path(socratic_seminar)
    click_on "Edit this socratic seminar", match: :first

    fill_in "Date", with: socratic_seminar.date
    fill_in "Seminar number", with: socratic_seminar.seminar_number
    click_on "Update Socratic seminar"

    expect(page).to have_text("Socratic seminar was successfully updated")
    click_on "Back"
  end

  it "destroys a Socratic seminar" do
    visit socratic_seminar_path(socratic_seminar)
    click_on "Destroy this socratic seminar", match: :first

    expect(page).to have_text("Socratic seminar was successfully destroyed")
  end
end