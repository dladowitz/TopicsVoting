FactoryBot.define do
  factory :socratic_seminar do
    after(:build) do |seminar, evaluator|
      n = FactoryBot.generate(:seminar_sequence)
      seminar.seminar_number = n
      seminar.date = n.months.from_now
      
      # This is ensuring that the builder_sf_link is always 2 digits long. So 1 becomes 01, 2 becomes 02, and 12 stays as 12.
      seminar.builder_sf_link = "https://www.bitcoinbuildersf.com/builder-#{n.to_s.rjust(2, '0')}/"
    end
  end
end

FactoryBot.define do
  sequence :seminar_sequence
end