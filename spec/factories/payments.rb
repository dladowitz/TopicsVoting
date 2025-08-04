FactoryBot.define do
  factory :payment do
    association :topic
    sequence(:payment_hash) { |n| "payment_hash_#{n}" }
    amount { 1000 }
    paid { false }
  end
end
