require 'rails_helper'

RSpec.describe TogglesController, type: :controller do
  describe "POST #increment" do
    context "with existing toggle" do
      let!(:toggle) { create(:toggle, name: "test_toggle", count: 5) }

      it "increments the toggle count" do
        expect {
          post :increment, params: { name: "test_toggle" }
        }.to change { toggle.reload.count }.from(5).to(6)
      end

      it "returns success JSON response" do
        post :increment, params: { name: "test_toggle" }

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          "success" => true,
          "count" => 6
        )
      end
    end

    context "with non-existing toggle" do
      it "returns not found status and error message" do
        post :increment, params: { name: "non_existing_toggle" }

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response).to include(
          "success" => false,
          "error" => "Toggle not found"
        )
      end
    end
  end

  describe "GET #sats_vs_bitcoin" do
    context "when both toggles exist" do
      let!(:btc_toggle) { create(:toggle, name: "btc_preference", count: 10) }
      let!(:sats_toggle) { create(:toggle, name: "sats_preference", count: 15) }

      it "assigns the correct counts" do
        get :sats_vs_bitcoin

        expect(assigns(:btc_count)).to eq(10)
        expect(assigns(:sats_count)).to eq(15)
      end

      it "renders the sats_vs_bitcoin template" do
        get :sats_vs_bitcoin
        expect(response).to render_template(:sats_vs_bitcoin)
      end
    end
  end
end
