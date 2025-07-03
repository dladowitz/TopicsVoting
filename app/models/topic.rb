class Topic < ApplicationRecord
    has_many :payments

    def individial_payments
        payments.where(paid: true).count
    end
end
