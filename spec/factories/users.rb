FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { "participant" }

    trait :admin do
      role { "admin" }
    end

    trait :moderator do
      role { "moderator" }
    end

    trait :participant do
      role { "participant" }
    end
  end
end
