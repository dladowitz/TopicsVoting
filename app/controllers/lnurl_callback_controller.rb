# Controller for handling LNURL callback requests
# Processes Lightning Network payment requests and generates invoices
class LnurlCallbackController < ApplicationController
  # Base URL for LNBits API
  # @see https://github.com/lnbits/lnbits
  LNBits_API_URL = "https://demo.lnbits.com/api/v1/payments"

  # Gets the LNBits admin API key from environment
  # @return [String] LNBits API key
  def lnbits_api_key
    ENV["LNBITS_ADMIN_API_KEY"]
  end

  # Handles LNURL callback requests and generates Lightning invoices
  # @return [Hash] Lightning invoice data including payment request
  # @raise [ActionController::ParameterMissing] if required parameters are missing
  # @raise [ActiveRecord::RecordNotFound] if topic is not found
  def show
    topic = Topic.find(params[:id])
    amount_msat = params[:amount].to_i
    amount_sat = amount_msat / 1000

    if amount_sat <= 0
      render json: { error: "Invalid amount" }, status: :unprocessable_content
      return
    end

    response = Faraday.post(LNBits_API_URL) do |req|
      req.headers["X-Api-Key"] = lnbits_api_key
      req.headers["Content-Type"] = "application/json"
      req.body = {
        out: false,
        amount: amount_sat,
        memo: "Vote for topic: #{topic.name}",
        webhook: webhook_url,
        extra: { topic_id: topic.id }
      }.to_json
    end

    invoice_data = JSON.parse(response.body)
    topic.payments.create!(
      payment_hash: invoice_data["payment_hash"],
      amount: amount_sat
    )

    render json: { pr: invoice_data["bolt11"], routes: [] }
  end
end
