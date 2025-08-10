# Controller for handling Lightning Network payment webhooks
class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token

  # Processes incoming payment webhooks from LNBits
  # Updates payment status and topic votes/sats when payment is confirmed
  #
  # @return [void]
  # @note Expects double-wrapped JSON payload with payment_hash and amount
  # @note Amount is received in millisats and converted to sats
  def create
    return head :bad_request if request.body.size <= 0

    # Not sure why but this seems to be a double wrapped JSON string
    payment_hash = JSON.parse(JSON.parse(request.body.read))["payment_hash"]
    amount = JSON.parse(JSON.parse(request.body.read))["amount"] / 1000 # Comes in as millisats

    if payment_hash.present?
      payment = Payment.find_by(payment_hash: payment_hash)
      if payment
        payment.update(paid: true)
        topic = payment.topic
        topic.sats_received = (topic.sats_received || 0) + payment.amount
        topic.votes = (topic.votes || 0) + 1
        topic.save!
        head :ok
      else
        head :not_found
      end
    else
      head :bad_request
    end
  end
end
