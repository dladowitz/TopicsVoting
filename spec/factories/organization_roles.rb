# frozen_string_literal: true

FactoryBot.define do
  factory :organization_role do
    user
    organization
    role { "admin" }

    trait :admin do
      role { "admin" }
    end

    trait :moderator do
      role { "moderator" }
    end
  end
end
