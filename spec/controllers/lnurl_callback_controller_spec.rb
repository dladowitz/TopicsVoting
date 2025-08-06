require 'rails_helper'

RSpec.describe LnurlCallbackController, type: :controller do
  let(:topic) { create(:topic, name: "Test Topic") }
  let(:amount_msat) { 1_000_000 } # 1000 sats in millisats
  let(:api_key) { "test_api_key" }
  let(:api_response) do
    {
      "payment_hash" => "test_payment_hash",
      "bolt11" => "test_bolt11_invoice",
      "payment_request" => "test_payment_request"
    }
  end

  before do
    allow(ENV).to receive(:[]).and_return(nil)
    allow(ENV).to receive(:[]).with("LNBITS_ADMIN_API_KEY").and_return(api_key)
  end

  def webhook_url
    "http://test.host/webhook"
  end

  describe "GET #show" do
    context "with valid parameters" do
      before do
        stub_request(:post, LnurlCallbackController::LNBits_API_URL)
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/json',
              'User-Agent' => /Faraday v.*/,
              'X-Api-Key' => api_key
            }
          )
          .to_return(
            status: 200,
            body: api_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "creates a new payment record" do
        expect {
          get :show, params: { id: topic.id, amount: amount_msat }
        }.to change(Payment, :count).by(1)

        payment = Payment.last
        expect(payment.topic).to eq(topic)
        expect(payment.payment_hash).to eq("test_payment_hash")
        expect(payment.amount).to eq(amount_msat / 1000)
      end

      it "returns the correct JSON response" do
        get :show, params: { id: topic.id, amount: amount_msat }

        expect(response).to have_http_status(:success)
        expect(response.content_type).to include("application/json")

        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          "pr" => "test_bolt11_invoice",
          "routes" => []
        )
      end
    end

    context "with invalid topic id" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          get :show, params: { id: -1, amount: amount_msat }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when LNBits API fails" do
      before do
        stub_request(:post, LnurlCallbackController::LNBits_API_URL)
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/json',
              'User-Agent' => /Faraday v.*/,
              'X-Api-Key' => api_key
            }
          )
          .to_return(status: 500, body: "Internal Server Error")
      end

      it "raises an error and does not create a payment" do
        expect {
          get :show, params: { id: topic.id, amount: amount_msat }
        }.to raise_error(JSON::ParserError)
          .and change(Payment, :count).by(0)
      end
    end

    context "with invalid amount parameter" do
      before do
        stub_request(:post, LnurlCallbackController::LNBits_API_URL)
          .with(
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/json',
              'User-Agent' => /Faraday v.*/,
              'X-Api-Key' => api_key
            }
          )
          .to_return(
            status: 200,
            body: api_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "returns error for invalid amount" do
        get :show, params: { id: topic.id, amount: "invalid" }

        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response).to include("error" => "Invalid amount")
        expect(Payment.count).to eq(0)
      end
    end
  end
end
