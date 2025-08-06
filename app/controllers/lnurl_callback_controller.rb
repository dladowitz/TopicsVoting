# GET /lnurl-callback?topic_id=42&amount=1000
class LnurlCallbackController < ApplicationController
  LNBits_API_URL = "https://demo.lnbits.com/api/v1/payments"
  def lnbits_api_key
    ENV["LNBITS_ADMIN_API_KEY"]
  end

  def show
    topic = Topic.find(params[:id])
    amount_msat = params[:amount].to_i
    amount_sat = amount_msat / 1000

    if amount_sat <= 0
      render json: { error: "Invalid amount" }, status: :unprocessable_entity
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

    # puts "\n\n>>>> invoice_data: #{invoice_data}\n\n"
    # puts "\n\n>>>> json: { pr: #{invoice_data['bolt11']}, routes: [] }"

    render json: { pr: invoice_data["bolt11"], routes: [] }
  end
end
