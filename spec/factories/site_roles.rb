# frozen_string_literal: true

FactoryBot.define do
  factory :site_role do
    user
    role { 'admin' }
  end
end
