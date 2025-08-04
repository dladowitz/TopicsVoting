require 'rails_helper'

RSpec.describe WebhookController, type: :controller do
  describe "POST #create" do
    let(:webhook_params) { { payment_hash: "test_hash", amount: 1000 } }

    it "handles non-existent payment hash" do
      # Note: The params are double-encoded in the original test
      post :create, body: JSON.generate(JSON.generate(webhook_params)),
                   format: :json

      expect(response).to have_http_status(:not_found)
    end
  end
end
