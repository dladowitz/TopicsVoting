FactoryBot.define do
  factory :section do
    name { Faker::Lorem.word }
    association :socratic_seminar

    # Generate unique order values for sections within the same seminar
    order { socratic_seminar.sections.count }
  end
end
