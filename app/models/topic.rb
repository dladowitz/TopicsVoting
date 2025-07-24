HOSTNAME = ENV["HOSTNAME"] # Make sure there is no "/" trailing slash in the ENV VAR

class Topic < ApplicationRecord
  belongs_to :socratic_seminar, optional: true
  belongs_to :section, optional: true
  has_many :payments

  after_create :set_lnurl


  def completed_payments_count
    payments.where(paid: true).count
  end

  private

  def set_lnurl
    update_column(:lnurl, generate_lnurl(self.id))
  end

  def generate_lnurl(topic_id)
    url = "#{HOSTNAME}/lnurl-pay/#{topic_id}"
    data = url.unpack("C*")
    words = Bech32.convert_bits(data, 8, 5, true)
    Bech32.encode("lnurl", words, :bech32)
  end
end
