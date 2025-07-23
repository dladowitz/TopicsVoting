class Topic < ApplicationRecord
  belongs_to :socratic_seminar, optional: false
  has_many :payments

  def individial_payments
    payments.where(paid: true).count
  end
end
