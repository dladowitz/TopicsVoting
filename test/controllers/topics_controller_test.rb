require "test_helper"

class TopicsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get topics_url
    assert_response :success
  end

  test "should get new" do
    get new_topic_url
    assert_response :success
  end

  test "should create topic" do
    post topics_url, params: { topic: { name: "Test Topic", description: "Test description" } }
    assert_redirected_to topics_url
  end
end
