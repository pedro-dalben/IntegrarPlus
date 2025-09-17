FactoryBot.define do
  factory :availability_exception do
    association :professional, factory: :professional
    association :agenda, factory: :agenda
    exception_date { Date.current + 1.day }
    exception_type { :unavailable }
    start_time { nil }
    end_time { nil }
    reason { 'Feriado' }
    active { true }
  end
end
