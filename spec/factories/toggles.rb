FactoryBot.define do
  factory :toggle do
    sequence(:name) { |n| "toggle_#{n}" }
    count { 0 }
  end
end
