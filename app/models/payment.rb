# Represents a Lightning Network payment for a topic
# @attr [Integer] topic_id ID of the topic being paid for
# @attr [Integer] amount Amount in satoshis
# @attr [Boolean] paid Whether the payment has been completed
# @attr [String] payment_hash Unique hash identifying the Lightning payment
class Payment < ApplicationRecord
  # @!attribute topic
  #   @return [Topic] The topic this payment is for
  belongs_to :topic
end
