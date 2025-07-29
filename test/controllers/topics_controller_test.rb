require "test_helper"

class TopicsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @socratic_seminar = socratic_seminars(:one)
  end

  test "should get index" do
    get socratic_seminar_topics_url(@socratic_seminar)
    assert_response :success
  end

  test "should get new" do
    get new_socratic_seminar_topic_url(@socratic_seminar)
    assert_response :success
  end

  test "should create topic" do
    assert_difference("Topic.count") do
      post socratic_seminar_topics_url(@socratic_seminar), params: { 
        topic: { 
          name: "Test Topic",
          section_id: sections(:one).id
        }
      }
    end

    assert_redirected_to socratic_seminar_topics_url(@socratic_seminar)
  end
end
