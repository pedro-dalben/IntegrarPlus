# frozen_string_literal: true

FactoryBot.define do
  factory :professional do
    full_name { 'João Silva' }
    sequence(:email) { |n| "professional#{n}@example.com" }
    sequence(:cpf) { |n| "#{n.to_s.rjust(11, '0')}" }
    phone { '(11) 99999-9999' }
    birth_date { 30.years.ago.to_date }
    active { true }
    workload_minutes { 2400 } # 40 hours
    hired_on { 1.year.ago.to_date }
    council_code { 'CRM123456' }

    trait :inactive do
      active { false }
    end

    trait :with_user do
      association :user
    end

    trait :with_contract_type do
      association :contract_type
    end

    trait :with_company do
      company_name { 'Empresa Exemplo Ltda' }
      cnpj { '12.345.678/0001-90' }
    end
  end
end
