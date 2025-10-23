# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }

    association :professional, factory: :professional

    trait :admin do
      after(:build) do |user|
        user.professional.groups << create(:group, name: 'admin')
      end
    end
  end
end
