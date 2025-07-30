FactoryBot.define do
  factory :socratic_seminar do
    # Start sequence from a high number to avoid conflicts with existing records
    sequence(:seminar_number) { |n| 1000 + n }
    date { Date.current }
    builder_sf_link { Faker::Internet.url }
  end
end 