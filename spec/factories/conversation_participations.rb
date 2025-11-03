# frozen_string_literal: true

FactoryBot.define do
  factory :conversation_participation do
    association :conversation, factory: :conversation
    association :participant, factory: :user
    role { :member }
    last_read_message_number { 0 }
    unread_count { 0 }
    notifications_enabled { true }
    notification_preferences { {} }
    joined_at { Time.current }

    trait :active do
      left_at { nil }
    end

    trait :owner do
      role { :owner }
    end

    trait :admin do
      role { :admin }
    end

    trait :member do
      role { :member }
    end

    trait :viewer do
      role { :viewer }
    end

    trait :left do
      left_at { Time.current }
    end
  end
end
