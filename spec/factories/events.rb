# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    title { 'Evento de Teste' }
    description { 'Descrição do evento de teste' }
    start_time { 1.hour.from_now }
    end_time { 2.hours.from_now }
    event_type { :consulta }
    status { :active }
    professional { create(:professional) }
    created_by { create(:professional) }
    agenda { create(:agenda, :draft) }

    trait :anamnese do
      event_type { :anamnese }
      title { 'Anamnese' }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :completed do
      status { :completed }
    end
  end
end
