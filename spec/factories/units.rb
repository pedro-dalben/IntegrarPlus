# frozen_string_literal: true

FactoryBot.define do
  factory :unit do
    sequence(:name) { |n| "Unit #{n}" }
  end
end
