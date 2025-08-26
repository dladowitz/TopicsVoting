# frozen_string_literal: true

# Represents a Lightning Network payout to an organization
# @attr [Integer] socratic_seminar_id ID of the seminar the payout is for
# @attr [Integer] organization_id ID of the organization being paid
# @attr [Integer] amount Amount in satoshis
# @attr [String] invoice The Lightning invoice used for payment (BOLT11 or BOLT12)
# @attr [String] invoice_type The type of invoice (bolt11, bolt12)
# @attr [String] payment_hash The payment hash from LNBits
# @attr [String] status Status of the payout (pending, completed, failed)
# @attr [String] memo Optional memo for the payment
# @attr [Hash] lnbits_response Full response from LNBits API
class Payout < ApplicationRecord
  belongs_to :socratic_seminar
  belongs_to :organization

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :invoice, presence: true
  validates :invoice_type, presence: true, inclusion: { in: %w[bolt11 bolt12] }
  validates :status, presence: true, inclusion: { in: %w[pending completed failed] }

  # Scopes
  scope :completed, -> { where(status: "completed") }
  scope :pending, -> { where(status: "pending") }
  scope :failed, -> { where(status: "failed") }

  # Gets the total amount paid out for a specific seminar
  # @param socratic_seminar [SocraticSeminar] The seminar to calculate for
  # @return [Integer] Total amount in satoshis
  def self.total_for_seminar(socratic_seminar)
    where(socratic_seminar: socratic_seminar, status: "completed").sum(:amount)
  end

  # Creates a new payout record and attempts to send the payment
  # @param socratic_seminar [SocraticSeminar] The seminar the payout is for
  # @param amount_sats [Integer] Amount to pay in satoshis
  # @param memo [String] Optional memo for the payment
  # @param bolt11_invoice [String] BOLT11 invoice to use for payment
  # @return [Payout] The created payout record
  # @raise [StandardError] if payment fails
  def self.create_and_pay(socratic_seminar, amount_sats, memo = nil, bolt11_invoice = nil)
    organization = socratic_seminar.organization

    # BOLT11 invoice is required for payment
    raise ArgumentError, "BOLT11 invoice is required for payment" if bolt11_invoice.blank?

    # Create the payout record
    payout = create!(
      socratic_seminar: socratic_seminar,
      organization: organization,
      amount: amount_sats,
      invoice: bolt11_invoice,
      invoice_type: "bolt11", # This may change in the future to support BOLT12
      status: "pending",
      memo: memo
    )

    begin
      # Attempt to send the payment
      lnbits_response = LightningPayoutService.pay_to_organization(
        organization,
        amount_sats,
        memo,
        bolt11_invoice
      )

      # Update the payout record with the response
      payout.update!(
        payment_hash: lnbits_response["payment_hash"],
        lnbits_response: lnbits_response,
        status: "completed"
      )

      payout
    rescue StandardError => e
      # Mark the payout as failed
      payout.update!(
        lnbits_response: { error: e.message },
        status: "failed"
      )
      raise e
    end
  end
end
