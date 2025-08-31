FactoryBot.define do
  factory :topic do
    name { Faker::Lorem.sentence }
    votes { 0 }
    sats_received { 0 }
    votable { true }
    payable { true }
    association :socratic_seminar
    association :section
  end
end
