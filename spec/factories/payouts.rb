# frozen_string_literal: true

FactoryBot.define do
  factory :payout do
    association :socratic_seminar
    association :organization
    amount { 1000 }
    invoice { "lno1qcp4256ypq" }
    invoice_type { "bolt11" }
    payment_hash { "test_payment_hash" }
    status { "completed" }
    memo { "Test payout" }
    lnbits_response { { "payment_hash" => "test_payment_hash", "status" => "completed" } }

    trait :pending do
      status { "pending" }
      payment_hash { nil }
      lnbits_response { nil }
    end

    trait :failed do
      status { "failed" }
      payment_hash { nil }
      lnbits_response { { "error" => "Payment failed" } }
    end
  end
end
