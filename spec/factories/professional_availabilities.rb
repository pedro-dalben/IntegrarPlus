# frozen_string_literal: true

FactoryBot.define do
  factory :professional_availability do
    association :professional, factory: :professional
    association :agenda, factory: :agenda
    day_of_week { :monday }
    start_time { '08:00' }
    end_time { '17:00' }
    active { true }
    notes { nil }
  end
end
