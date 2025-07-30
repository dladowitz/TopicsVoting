require "test_helper"

class WebhookControllerTest < ActionDispatch::IntegrationTest
  test "should handle webhook" do
    post webhook_url,
      params: JSON.generate(JSON.generate({ payment_hash: "test_hash", amount: 1000 })),
      headers: { "CONTENT_TYPE" => "application/json" }
    assert_response :not_found # Since the payment_hash doesn't exist
  end
end
