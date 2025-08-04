require 'rails_helper'

RSpec.describe WebhookController, type: :controller do
  describe "POST #create" do
    let(:webhook_params) { { payment_hash: "test_hash", amount: 1000 } }

    context "with empty request body" do
      it "returns bad request" do
        post :create, body: "", format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "with missing payment hash" do
      it "returns bad request" do
        post :create, body: JSON.generate(JSON.generate({ amount: 1000 })), format: :json
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "with non-existent payment hash" do
      it "returns not found" do
        post :create, body: JSON.generate(JSON.generate(webhook_params)), format: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with existing payment" do
      let!(:topic) { create(:topic, sats_received: 100, votes: 5) }
      let!(:payment) { create(:payment, payment_hash: "test_hash", amount: 1, topic: topic, paid: false) }

      it "updates payment and topic" do
        post :create, body: JSON.generate(JSON.generate(webhook_params)), format: :json

        expect(response).to have_http_status(:ok)

        # Verify payment was marked as paid
        payment.reload
        expect(payment.paid).to be true

        # Verify topic stats were updated
        topic.reload
        expect(topic.sats_received).to eq(101) # 100 + 1
        expect(topic.votes).to eq(6) # 5 + 1
      end

      context "with zero initial values" do
        let!(:topic) { create(:topic, sats_received: 0, votes: 0) }

        it "handles zero values correctly" do
          post :create, body: JSON.generate(JSON.generate(webhook_params)), format: :json

          expect(response).to have_http_status(:ok)

          topic.reload
          expect(topic.sats_received).to eq(1)
          expect(topic.votes).to eq(1)
        end
      end
    end
  end
end
