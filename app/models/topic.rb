HOSTNAME = ENV["HOSTNAME"] # Make sure there is no "/" trailing slash in the ENV VAR

# A Topic represents a discussion item within a Socratic Seminar
# @attr [String] name The name/title of the topic
# @attr [String] link Optional URL related to the topic
# @attr [Integer] votes Number of votes for this topic
# @attr [Integer] sats_received Number of satoshis received for this topic
# @attr [String] lnurl Lightning Network URL for payments

class Topic < ApplicationRecord
  belongs_to :section
  has_one :socratic_seminar, through: :section
  has_many :payments

  validates :name, presence: true
  # Custom validation for links to allow various URL schemes
  validate :validate_link, if: -> { link.present? }

  after_create :set_lnurl
  after_update_commit :broadcast_topic_update

  # @return [Integer] The number of completed payments for this topic
  def completed_payments_count
    payments.where(paid: true).count
  end

  private

  def validate_link
    # Try parsing as URI first
    begin
      uri = URI.parse(link)
      # Accept any scheme with a host, or special schemes like nostr:
      return if uri.scheme.present? && (uri.host.present? || uri.scheme == "nostr")
    rescue URI::InvalidURIError
      # If URI parsing fails, check if it looks like a URL/identifier
      return if link.match?(/\A[^\s]+\z/) # Accept any non-whitespace string
    end
    errors.add(:link, "must be a valid URL or identifier")
  end

  # Sets the LNURL for this topic after creation
  # @return [void]
  def set_lnurl
    update_column(:lnurl, generate_lnurl(self.id))
  end

  # Generates a LNURL for the given topic ID
  # @param [Integer] topic_id The ID of the topic
  # @return [String] The generated LNURL
  def generate_lnurl(topic_id)
    url = "#{HOSTNAME}/lnurl-pay/#{topic_id}"
    data = url.unpack("C*")
    words = Bech32.convert_bits(data, 8, 5, true)
    Bech32.encode("lnurl", words, :bech32)
  end

  # Broadcasts topic updates via ActionCable
  # @return [void]
  def broadcast_topic_update
    # puts "[Topic] Broadcasting update for topic ##{id} (votes: #{votes}, sats: #{sats_received})"
    ActionCable.server.broadcast(
      "topics",
      {
        id: id,
        votes: votes,
        sats_received: sats_received
      }
    )
  end
end
