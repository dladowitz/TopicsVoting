# frozen_string_literal: true

FactoryBot.define do
  factory :socratic_seminar do
    association :organization
    date { 1.month.from_now }
    sequence(:seminar_number)

    after(:build) do |seminar|
      # This is ensuring that the topics_list_url is always 2 digits long. So 1 becomes 01, 2 becomes 02, and 12 stays as 12.
      seminar.topics_list_url = "https://www.bitcoinbuildersf.com/builder-#{seminar.seminar_number.to_s.rjust(2, '0')}/"
    end

    trait :with_topics do
      after(:create) do |seminar|
        section = create(:section, socratic_seminar: seminar)
        create(:topic, section: section)
      end
    end
  end
end
