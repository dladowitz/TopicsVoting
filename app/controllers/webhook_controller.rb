class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    return head :bad_request if request.body.size <= 0

    payment_hash = JSON.parse(JSON.parse(request.body.read))["payment_hash"] # Not sure why but this seems to be a double wrapped JSON string
    amount = JSON.parse(JSON.parse(request.body.read))["amount"] / 1000 # Comes in as millisats
    puts "\n\n>>>> payment_hash: #{payment_hash}\n\n"
    puts "\n\n>>>> amount: #{amount}\n\n"

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
