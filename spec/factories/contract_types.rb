# frozen_string_literal: true

FactoryBot.define do
  factory :contract_type do
    name { 'CLT' }
    description { 'Consolidação das Leis do Trabalho' }
    active { true }
  end
end
