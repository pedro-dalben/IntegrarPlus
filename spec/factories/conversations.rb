# frozen_string_literal: true

FactoryBot.define do
  factory :conversation do
    sequence(:service) { |n| "service_#{n}" }
    sequence(:context_type) { |n| "ContextType#{n}" }
    sequence(:context_id) { |n| n }
    sequence(:scope) { |n| "scope_#{n}" }
    conversation_type { :group }
    status { :active }
    next_message_number { 1 }
    messages_count { 0 }

    trait :for_beneficiary do
      service { 'beneficiaries' }
      context_type { 'Beneficiary' }
      context_id { 1 }
      scope { 'general' }
    end
  end
end
