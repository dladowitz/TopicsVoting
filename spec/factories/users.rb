FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }

    trait :admin do
      after(:create) do |user|
        create(:site_role, user: user, role: 'admin')
      end
    end
  end
end
