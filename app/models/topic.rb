class Topic < ApplicationRecord
  belongs_to :socratic_seminar, optional: true
  belongs_to :section, optional: true
  has_many :payments

  def individial_payments
    payments.where(paid: true).count
  end
end
