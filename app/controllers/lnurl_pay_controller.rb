# GET /lnurl-pay/:id
class LnurlPayController < ApplicationController
    MIN_SAT_AMOUNT = 1_000 # 1 sat -> $0.001
    MAX_SAT_AMOUNT = 10_000_000 # 10_000 sat -> $10

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
