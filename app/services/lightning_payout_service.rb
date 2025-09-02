# frozen_string_literal: true

# Service for handling Lightning Network payouts to organizations
# Uses LNBits API to send payments to bolt12 invoices
class LightningPayoutService
  # Base URL for LNBits API
  # @see https://github.com/lnbits/lnbits
  LNBITS_API_URL = "https://demo.lnbits.com/api/v1/payments"
  LNBITS_DECODE_URL = "https://demo.lnbits.com/api/v1/payments/decode"

  # Gets the LNBits admin API key from environment
  # @return [String] LNBits API key
  def self.lnbits_api_key
    ENV["LNBITS_ADMIN_API_KEY"]
  end

  # Sends a Lightning payment to an organization using BOLT11 invoice
  # @param organization [Organization] The organization to pay
  # @param amount_sats [Integer] Amount to pay in satoshis
  # @param memo [String] Optional memo for the payment
  # @param bolt11_invoice [String] BOLT11 invoice to use for payment
  # @return [Hash] Response from LNBits API
  # @raise [ArgumentError] if no BOLT11 invoice is provided or amount is invalid
  # @raise [StandardError] if LNBits API request fails
  def self.pay_to_organization(organization, amount_sats, memo = nil, bolt11_invoice = nil)
    # Validate inputs
    raise ArgumentError, "Amount must be positive" if amount_sats <= 0
    raise ArgumentError, "BOLT11 invoice is required for payment" if bolt11_invoice.blank?

    # BOLT11 payment - this is what LNBits supports for outgoing payments
    payment_data = {
      out: true,
      bolt11: bolt11_invoice,
      amount: amount_sats
    }

    # Add memo if provided
    payment_data[:memo] = memo if memo.present?

    # puts "\n\n ->>>>>>>> Making BOLT11 payment: #{LNBITS_API_URL}"
    # puts payment_data.inspect

    # Make the API request
    response = Faraday.post(LNBITS_API_URL) do |req|
      req.headers["X-Api-Key"] = lnbits_api_key
      req.headers["Content-Type"] = "application/json"
      req.body = payment_data.to_json
    end

    # puts "\n\n ->>>>>>>> Response from BOLT11 payment: #{response.status} - #{response.body} \n\n"

    # Handle the response
    if response.success?
      JSON.parse(response.body)
    else
      error_message = "\n\n ->>>>>>>> LNBits API request failed: #{response.status} - #{response.body} \n\n"
      Rails.logger.error error_message
      raise StandardError, error_message
    end
  end

  # Calculates the total amount available for payout from a Socratic Seminar
  # @param socratic_seminar [SocraticSeminar] The seminar to calculate payout for
  # @return [Integer] Total amount in satoshis available for payout
  def self.calculate_available_payout(socratic_seminar)
    # Get total payments received for this seminar
    total_payments_received = socratic_seminar.topics.joins(:payments)
                                             .where(payments: { paid: true })
                                             .sum("payments.amount")

    total_payouts = Payout.total_for_seminar(socratic_seminar)

    total_payments_received - total_payouts
  end

  # Checks if a payout can be made for a Socratic Seminar
  # @param socratic_seminar [SocraticSeminar] The seminar to check
  # @return [Boolean] True if payout is possible
  def self.can_payout?(socratic_seminar)
    return false if calculate_available_payout(socratic_seminar) <= 0

    true
  end

  # Decodes a BOLT11 invoice to extract its amount and other details
  # @param bolt11_invoice [String] The BOLT11 invoice to decode
  # @return [Hash] Decoded invoice information including amount
  # @raise [StandardError] if invoice cannot be decoded
  def self.decode_bolt11_invoice(bolt11_invoice)
    # puts "\n\n ->>>>>>>> Decoding BOLT11 invoice: #{bolt11_invoice} \n\n"
    # Make the API request to decode the invoice
    response = Faraday.post(LNBITS_DECODE_URL) do |req|
      req.headers["X-Api-Key"] = lnbits_api_key
      req.headers["Content-Type"] = "application/json"
      req.body = { data: bolt11_invoice }.to_json
    end

    # puts "\n\n ->>>>>>>> Response from BOLT11 invoice decode: Status: #{response.status} - Body: #{response.body} \n\n"

    if response.success?
      JSON.parse(response.body)
    else
      error_message = "Failed to decode BOLT11 invoice: #{response.status} - #{response.body}"
      Rails.logger.error error_message
      raise StandardError, error_message
    end
  end

  # Validates that a BOLT11 invoice amount matches the expected amount
  # @param bolt11_invoice [String] The BOLT11 invoice to validate
  # @param expected_amount_sats [Integer] The expected amount in satoshis
  # @return [Boolean] True if amount matches, false otherwise
  # @raise [StandardError] if invoice cannot be decoded
  def self.validate_bolt11_amount(bolt11_invoice, expected_amount_sats)
    # puts "\n\n ->>>>>>>> Validating BOLT11 invoice amount: #{bolt11_invoice} - Amount available: #{expected_amount_sats} \n\n"
    decoded = decode_bolt11_invoice(bolt11_invoice)

    # Extract amount from decoded invoice (amount is typically in millisats)
    invoice_amount_msat = decoded["amount_msat"]
    invoice_amount_sats = invoice_amount_msat / 1000 if invoice_amount_msat

    # Check if amountless invoice
    if invoice_amount_sats.nil? || invoice_amount_sats == 0
      raise StandardError, "Amountless invoices are not supported. Please provide an invoice with a specific amount."
    end

    # Validate amount is not larger than expected
    if invoice_amount_sats > expected_amount_sats
      raise StandardError, "Invoice amount (#{invoice_amount_sats} sats) is larger than available amount (#{expected_amount_sats} sats). Please provide an invoice for #{expected_amount_sats} sats or less."
    end

    true
  end
end
