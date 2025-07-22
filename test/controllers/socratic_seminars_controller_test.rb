require "test_helper"

class SocraticSeminarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @socratic_seminar = socratic_seminars(:one)
  end

  test "should get index" do
    get socratic_seminars_url
    assert_response :success
  end

  test "should get new" do
    get new_socratic_seminar_url
    assert_response :success
  end

  test "should create socratic_seminar" do
    assert_difference("SocraticSeminar.count") do
      post socratic_seminars_url, params: { socratic_seminar: { date: @socratic_seminar.date, seminar_number: @socratic_seminar.seminar_number } }
    end

    assert_redirected_to socratic_seminar_url(SocraticSeminar.last)
  end

  test "should show socratic_seminar" do
    get socratic_seminar_url(@socratic_seminar)
    assert_response :success
  end

  test "should get edit" do
    get edit_socratic_seminar_url(@socratic_seminar)
    assert_response :success
  end

  test "should update socratic_seminar" do
    patch socratic_seminar_url(@socratic_seminar), params: { socratic_seminar: { date: @socratic_seminar.date, seminar_number: @socratic_seminar.seminar_number } }
    assert_redirected_to socratic_seminar_url(@socratic_seminar)
  end

  test "should destroy socratic_seminar" do
    assert_difference("SocraticSeminar.count", -1) do
      delete socratic_seminar_url(@socratic_seminar)
    end

    assert_redirected_to socratic_seminars_url
  end
end
