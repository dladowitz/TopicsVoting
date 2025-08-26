# frozen_string_literal: true

require "rails_helper"

RSpec.describe LightningPayoutService do
      let(:organization) { create(:organization, bolt12_invoice: "lno1qcp4256ypq") }
    let(:bolt11_invoice) { "lnbc1testinvoice" }
  let(:socratic_seminar) { create(:socratic_seminar, organization: organization) }
  let(:section) { create(:section, socratic_seminar: socratic_seminar) }
  let(:topic) { create(:topic, section: section) }
  let(:payment) { create(:payment, topic: topic, amount: 1000, paid: true) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("LNBITS_ADMIN_API_KEY").and_return("test_api_key")
  end

  describe ".lnbits_api_key" do
    it "returns the API key from environment" do
      expect(described_class.lnbits_api_key).to eq("test_api_key")
    end
  end

  describe ".pay_to_organization" do
    let(:amount_sats) { 1000 }
    let(:memo) { "Test payment" }
    let(:success_response) { { "payment_hash" => "test_hash", "status" => "completed" } }

    context "with valid parameters" do
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

      it "sends a payment request to LNBits" do
        result = described_class.pay_to_organization(organization, amount_sats, memo, bolt11_invoice)
        expect(result).to eq(success_response)
      end
    end

    context "when no bolt11_invoice is provided" do
      it "raises an ArgumentError" do
        expect do
          described_class.pay_to_organization(organization, amount_sats, memo)
        end.to raise_error(ArgumentError, "BOLT11 invoice is required for payment")
      end
    end

    context "when amount is invalid" do
      it "raises an ArgumentError for zero amount" do
        expect do
          described_class.pay_to_organization(organization, 0, memo)
        end.to raise_error(ArgumentError, "Amount must be positive")
      end

      it "raises an ArgumentError for negative amount" do
        expect do
          described_class.pay_to_organization(organization, -100, memo)
        end.to raise_error(ArgumentError, "Amount must be positive")
      end
    end

    context "when LNBits API request fails" do
      before do
        stub_request(:post, "https://demo.lnbits.com/api/v1/payments")
          .to_return(status: 400, body: "Bad Request")
      end

      it "raises a StandardError with the error message" do
        expect do
          described_class.pay_to_organization(organization, amount_sats, memo, bolt11_invoice)
        end.to raise_error(StandardError, /LNBits API request failed/)
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
              bolt11: bolt11_invoice,
              amount: amount_sats
            }.to_json
          )
          .to_return(status: 200, body: success_response.to_json)
      end

      it "sends payment request without memo" do
        result = described_class.pay_to_organization(organization, amount_sats, nil, bolt11_invoice)
        expect(result).to eq(success_response)
      end
    end
  end

  describe ".calculate_available_payout" do
    let!(:payment) { create(:payment, topic: topic, amount: 1000, paid: true) }

    it "calculates the total available for payout" do
      result = described_class.calculate_available_payout(socratic_seminar)
      expect(result).to eq(1000)
    end

    context "when there are no payments" do
      let(:empty_seminar) { create(:socratic_seminar, organization: organization) }

      it "returns zero" do
        result = described_class.calculate_available_payout(empty_seminar)
        expect(result).to eq(0)
      end
    end

    context "when there are multiple payments" do
      let!(:payment) { create(:payment, topic: topic, amount: 1000, paid: true) }
      let!(:payment2) { create(:payment, topic: topic, amount: 500, paid: true) }

      it "sums all paid payments" do
        result = described_class.calculate_available_payout(socratic_seminar)
        expect(result).to eq(1500)
      end
    end
  end

  describe ".can_payout?" do
    let!(:payment) { create(:payment, topic: topic, amount: 1000, paid: true) }

    context "when payout is possible" do
      it "returns true" do
        result = described_class.can_payout?(socratic_seminar)
        expect(result).to be true
      end
    end

    context "when organization has no bolt12_invoice" do
      let(:organization_without_invoice) { create(:organization, bolt12_invoice: nil) }
      let(:seminar_without_invoice) { create(:socratic_seminar, organization: organization_without_invoice) }

      it "returns false" do
        result = described_class.can_payout?(seminar_without_invoice)
        expect(result).to be false
      end
    end

    context "when no funds are available" do
      let(:empty_seminar) { create(:socratic_seminar, organization: organization) }

      it "returns false" do
        result = described_class.can_payout?(empty_seminar)
        expect(result).to be false
      end
    end
  end

  describe ".decode_bolt11_invoice" do
    let(:bolt11_invoice) { "lnbc1testinvoice" }
    let(:decoded_response) { { "amount" => 1000000, "description" => "Test invoice" } }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("LNBITS_ADMIN_API_KEY").and_return("test_api_key")
    end

    context "when decode is successful" do
      before do
        stub_request(:post, "https://demo.lnbits.com/api/v1/payments/decode")
          .with(
            headers: {
              "X-Api-Key" => "test_api_key",
              "Content-Type" => "application/json"
            },
            body: { data: bolt11_invoice }.to_json
          )
          .to_return(status: 200, body: decoded_response.to_json)
      end

      it "returns decoded invoice information" do
        result = described_class.decode_bolt11_invoice(bolt11_invoice)
        expect(result).to eq(decoded_response)
      end
    end

    context "when decode fails" do
      before do
        stub_request(:post, "https://demo.lnbits.com/api/v1/payments/decode")
          .to_return(status: 400, body: "Invalid invoice")
      end

      it "raises a StandardError" do
        expect do
          described_class.decode_bolt11_invoice(bolt11_invoice)
        end.to raise_error(StandardError, /Failed to decode BOLT11 invoice/)
      end
    end
  end

  describe ".validate_bolt11_amount" do
    let(:bolt11_invoice) { "lnbc1testinvoice" }
    let(:expected_amount_sats) { 1000 }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("LNBITS_ADMIN_API_KEY").and_return("test_api_key")
    end

    context "when amount matches" do
      before do
        stub_request(:post, "https://demo.lnbits.com/api/v1/payments/decode")
          .with(
            headers: {
              "X-Api-Key" => "test_api_key",
              "Content-Type" => "application/json"
            },
            body: { data: bolt11_invoice }.to_json
          )
          .to_return(status: 200, body: { "amount_msat" => 1000000 }.to_json) # 1000 sats in millisats
      end

      it "returns true" do
        result = described_class.validate_bolt11_amount(bolt11_invoice, expected_amount_sats)
        expect(result).to be true
      end
    end

    context "when amount is larger than expected" do
      before do
        stub_request(:post, "https://demo.lnbits.com/api/v1/payments/decode")
          .to_return(status: 200, body: { "amount_msat" => 2000000 }.to_json) # 2000 sats in millisats
      end

      it "raises a StandardError" do
        expect do
          described_class.validate_bolt11_amount(bolt11_invoice, expected_amount_sats)
        end.to raise_error(StandardError, /Invoice amount \(2000 sats\) is larger than available amount \(1000 sats\)/)
      end
    end

    context "when amount is less than expected" do
      before do
        stub_request(:post, "https://demo.lnbits.com/api/v1/payments/decode")
          .to_return(status: 200, body: { "amount_msat" => 500000 }.to_json) # 500 sats in millisats
      end

      it "returns true" do
        result = described_class.validate_bolt11_amount(bolt11_invoice, expected_amount_sats)
        expect(result).to be true
      end
    end

    context "when invoice is amountless" do
      before do
        stub_request(:post, "https://demo.lnbits.com/api/v1/payments/decode")
          .to_return(status: 200, body: { "amount_msat" => 0 }.to_json)
      end

      it "raises a StandardError" do
        expect do
          described_class.validate_bolt11_amount(bolt11_invoice, expected_amount_sats)
        end.to raise_error(StandardError, /Amountless invoices are not supported/)
      end
    end
  end
end
