require 'rails_helper'

RSpec.describe LnurlPayController, type: :controller do
  let(:topic) { create(:topic, name: "Test Topic") }

  describe "GET #show" do
    context "with valid topic id" do
      before do
        get :show, params: { id: topic.id }
      end

      it "returns a successful response" do
        expect(response).to be_successful
      end

      it "returns JSON content type" do
        expect(response.content_type).to include("application/json")
      end

      it "returns correct LNURL-pay response structure" do
        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          "tag" => "payRequest",
          "callback" => lnurl_callback_url(id: topic.id),
          "metadata" => "[[\"text/plain\", \"Upvote: #{topic.name}\"]]",
          "minSendable" => 1_000,
          "maxSendable" => 10_000_000,
          "commentAllowed" => 0
        )
      end

      it "uses correct min/max sendable values" do
        json_response = JSON.parse(response.body)
        expect(json_response["minSendable"]).to eq(LnurlPayController::MIN_SAT_AMOUNT)
        expect(json_response["maxSendable"]).to eq(LnurlPayController::MAX_SAT_AMOUNT)
      end
    end

    context "with invalid topic id" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          get :show, params: { id: -1 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
