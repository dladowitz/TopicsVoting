require 'rails_helper'

RSpec.describe "Socratic Seminars", type: :system do
  let(:socratic_seminar) { create(:socratic_seminar) }

  before do
    driven_by(:selenium_chrome_headless)
  end

  it "visiting the index" do
    visit socratic_seminars_path
    expect(page).to have_selector(".seminar-title", text: "₿uilder Voting")
  end

  context "with admin mode" do
    before do
      # Enable admin mode by visiting with mode=admin
      visit socratic_seminars_path(mode: 'admin')
    end

    it "creates a socratic seminar" do
      visit socratic_seminars_path
      click_on "New ₿uilder Seminar"

      fill_in "Date", with: socratic_seminar.date
      fill_in "Seminar number", with: socratic_seminar.seminar_number + 1
      click_on "Create Socratic seminar"

      expect(page).to have_text("Socratic seminar was successfully created")
      click_on "Back to socratic seminars"
    end

    it "updates a Socratic seminar" do
      visit socratic_seminar_path(socratic_seminar, mode: 'admin')
      click_on "Edit this socratic seminar"

      fill_in "Date", with: socratic_seminar.date
      fill_in "Seminar number", with: socratic_seminar.seminar_number
      click_on "Update Socratic seminar"

      expect(page).to have_text("Socratic seminar was successfully updated")
      click_on "Back to socratic seminars"
    end

    it "destroys a Socratic seminar" do
      visit socratic_seminar_path(socratic_seminar, mode: 'admin')
      click_button "Destroy this socratic seminar"

      expect(page).to have_text("Socratic seminar was successfully destroyed")
    end
  end
end
