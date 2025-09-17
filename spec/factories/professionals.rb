FactoryBot.define do
  factory :professional do
    sequence(:full_name) { |n| "Dr. João Silva #{n}" }
    sequence(:email) { |n| "joao#{n}@example.com" }
    phone { '11999999999' }
    sequence(:cpf) { |n| "#{n.to_s.rjust(11, '0')}" }
    active { true }
    contract_type { build(:contract_type) }
    hired_on { Date.current }
    workload_minutes { 40 * 60 } # 40 hours per week
    sequence(:council_code) { |n| "#{n.to_s.rjust(6, '0')}" }
    company_name { 'Clínica Exemplo' }
    sequence(:cnpj) { |n| "#{n.to_s.rjust(14, '0')}" }
  end
end
