# Controller for handling LNURL-pay requests
# Provides LNURL metadata for Lightning Network payments
class LnurlPayController < ApplicationController
  # Minimum amount in satoshis that can be paid (1,000 sats ≈ $0.001 (in 2025))
  MIN_SAT_AMOUNT = 1_000

  # Maximum amount in satoshis that can be paid (10,000,000 sats ≈ $10 (in 2025))
  MAX_SAT_AMOUNT = 10_000_000

  # Returns LNURL-pay metadata for a topic
  # @return [Hash] LNURL-pay metadata including callback URL and payment limits
  # @see https://github.com/lnurl/luds/blob/luds/06.md LNURL-pay specification
  def show
    topic = Topic.find(params[:id])
    render json: {
      tag: "payRequest",
      callback: lnurl_callback_url(id: topic.id),
      metadata: "[[\"text/plain\", \"Upvote: #{topic.name}\"]]",
      minSendable: MIN_SAT_AMOUNT,
      maxSendable: MAX_SAT_AMOUNT,
      commentAllowed: 0
    }
  end
end
