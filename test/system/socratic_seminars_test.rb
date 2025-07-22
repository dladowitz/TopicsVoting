require "application_system_test_case"

class SocraticSeminarsTest < ApplicationSystemTestCase
  setup do
    @socratic_seminar = socratic_seminars(:one)
  end

  test "visiting the index" do
    visit socratic_seminars_url
    assert_selector "h1", text: "Socratic seminars"
  end

  test "should create socratic seminar" do
    visit socratic_seminars_url
    click_on "New socratic seminar"

    fill_in "Date", with: @socratic_seminar.date
    fill_in "Seminar number", with: @socratic_seminar.seminar_number
    click_on "Create Socratic seminar"

    assert_text "Socratic seminar was successfully created"
    click_on "Back"
  end

  test "should update Socratic seminar" do
    visit socratic_seminar_url(@socratic_seminar)
    click_on "Edit this socratic seminar", match: :first

    fill_in "Date", with: @socratic_seminar.date
    fill_in "Seminar number", with: @socratic_seminar.seminar_number
    click_on "Update Socratic seminar"

    assert_text "Socratic seminar was successfully updated"
    click_on "Back"
  end

  test "should destroy Socratic seminar" do
    visit socratic_seminar_url(@socratic_seminar)
    click_on "Destroy this socratic seminar", match: :first

    assert_text "Socratic seminar was successfully destroyed"
  end
end
