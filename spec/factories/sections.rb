FactoryBot.define do
  factory :section do
    name { Faker::Lorem.word }
    association :socratic_seminar
  end
end
