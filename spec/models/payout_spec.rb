# frozen_string_literal: true

require "rails_helper"

RSpec.describe Payout, type: :model do
  let(:organization) { create(:organization, bolt12_invoice: "lno1qcp4256ypq") }
  let(:socratic_seminar) { create(:socratic_seminar, organization: organization) }

  describe "associations" do
    it { should belong_to(:socratic_seminar) }
    it { should belong_to(:organization) }
  end

  describe "validations" do
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should validate_presence_of(:invoice) }
    it { should validate_presence_of(:invoice_type) }
    it { should validate_inclusion_of(:invoice_type).in_array(%w[bolt11 bolt12]) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[pending completed failed]) }
  end

  describe "scopes" do
    let!(:completed_payout) { create(:payout, status: "completed") }
    let!(:pending_payout) { create(:payout, status: "pending") }
    let!(:failed_payout) { create(:payout, status: "failed") }

    describe ".completed" do
      it "returns only completed payouts" do
        expect(described_class.completed).to include(completed_payout)
        expect(described_class.completed).not_to include(pending_payout, failed_payout)
      end
    end

    describe ".pending" do
      it "returns only pending payouts" do
        expect(described_class.pending).to include(pending_payout)
        expect(described_class.pending).not_to include(completed_payout, failed_payout)
      end
    end

    describe ".failed" do
      it "returns only failed payouts" do
        expect(described_class.failed).to include(failed_payout)
        expect(described_class.failed).not_to include(completed_payout, pending_payout)
      end
    end
  end

  describe ".total_for_seminar" do
    let!(:payout1) { create(:payout, socratic_seminar: socratic_seminar, amount: 1000, status: "completed") }
    let!(:payout2) { create(:payout, socratic_seminar: socratic_seminar, amount: 500, status: "completed") }
    let!(:pending_payout) { create(:payout, socratic_seminar: socratic_seminar, amount: 200, status: "pending") }
    let!(:other_seminar_payout) { create(:payout, amount: 300, status: "completed") }

    it "returns the total amount of completed payouts for the seminar" do
      result = described_class.total_for_seminar(socratic_seminar)
      expect(result).to eq(1500) # 1000 + 500, excluding pending and other seminar
    end
  end

  describe ".create_and_pay" do
    let(:amount_sats) { 1000 }
    let(:memo) { "Test payout" }
    let(:success_response) { { "payment_hash" => "test_hash", "status" => "completed" } }

      before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("LNBITS_ADMIN_API_KEY").and_return("test_api_key")
  end

    context "when payment is successful" do
      before do
                  stub_request(:post, "https://demo.lnbits.com/api/v1/payments")
            .with(
              headers: {
                "X-Api-Key" => "test_api_key",
                "Content-Type" => "application/json"
              },
              body: {
                out: true,
                bolt11: "lnbc1testinvoice",
                amount: amount_sats,
                memo: memo
              }.to_json
            )
            .to_return(status: 200, body: success_response.to_json)
      end

      it "creates a payout record and marks it as completed" do
        expect do
          payout = described_class.create_and_pay(socratic_seminar, amount_sats, memo, "lnbc1testinvoice")
          expect(payout.socratic_seminar).to eq(socratic_seminar)
          expect(payout.organization).to eq(organization)
          expect(payout.amount).to eq(amount_sats)
          expect(payout.invoice).to eq("lnbc1testinvoice")
          expect(payout.invoice_type).to eq("bolt11")
          expect(payout.status).to eq("completed")
          expect(payout.memo).to eq(memo)
          expect(payout.payment_hash).to eq("test_hash")
          expect(payout.lnbits_response).to eq(success_response)
        end.to change(described_class, :count).by(1)
      end
    end

    context "when payment fails" do
      before do
        stub_request(:post, "https://demo.lnbits.com/api/v1/payments")
          .to_return(status: 400, body: "Bad Request")
      end

      it "creates a payout record and marks it as failed" do
        expect do
          expect do
            described_class.create_and_pay(socratic_seminar, amount_sats, memo, "lnbc1testinvoice")
          end.to raise_error(StandardError, /LNBits API request failed/)
        end.to change(described_class, :count).by(1)

        payout = described_class.last
        expect(payout.status).to eq("failed")
        expect(payout.lnbits_response).to include("error")
      end
    end

    context "when memo is not provided" do
      before do
        stub_request(:post, "https://demo.lnbits.com/api/v1/payments")
          .with(
            headers: {
              "X-Api-Key" => "test_api_key",
              "Content-Type" => "application/json"
            },
            body: {
              out: true,
              bolt11: "lnbc1testinvoice",
              amount: amount_sats
            }.to_json
          )
          .to_return(status: 200, body: success_response.to_json)
      end

      it "creates a payout record without memo" do
        payout = described_class.create_and_pay(socratic_seminar, amount_sats, nil, "lnbc1testinvoice")
        expect(payout.memo).to be_nil
      end
    end
  end
end
