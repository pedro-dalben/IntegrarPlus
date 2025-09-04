FactoryBot.define do
  factory :event do
    title { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    start_time { 1.hour.from_now }
    end_time { 2.hours.from_now }
    event_type { :personal }
    visibility_level { :publicly_visible }
    source_context { nil }
    status { :active }

    association :professional
    association :created_by, factory: :professional

    trait :consulta do
      event_type { :consulta }
      title { "Consulta com #{Faker::Name.name}" }
    end

    trait :atendimento do
      event_type { :atendimento }
      title { "Atendimento - #{Faker::Company.name}" }
    end

    trait :reuniao do
      event_type { :reuniao }
      title { "Reunião - #{Faker::Company.name}" }
    end

    trait :outro do
      event_type { :outro }
      title { 'Outro evento' }
    end

    trait :personal_private do
      visibility_level { :personal_private }
    end

    trait :restricted do
      visibility_level { :restricted }
    end

    trait :publicly_visible do
      visibility_level { :publicly_visible }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :completed do
      status { :completed }
    end

    trait :short_duration do
      start_time { 1.hour.from_now }
      end_time { 1.hour.from_now + 30.minutes }
    end

    trait :long_duration do
      start_time { 1.hour.from_now }
      end_time { 1.hour.from_now + 4.hours }
    end

    trait :morning do
      start_time { Date.current.beginning_of_day + 9.hours }
      end_time { Date.current.beginning_of_day + 10.hours }
    end

    trait :afternoon do
      start_time { Date.current.beginning_of_day + 14.hours }
      end_time { Date.current.beginning_of_day + 15.hours }
    end

    trait :evening do
      start_time { Date.current.beginning_of_day + 18.hours }
      end_time { Date.current.beginning_of_day + 19.hours }
    end

    trait :with_source_context do
      source_context { "appointment_id=#{Faker::Number.number(digits: 6)}" }
    end

    trait :conflicting do
      start_time { 1.hour.from_now + 30.minutes }
      end_time { 2.hours.from_now + 30.minutes }
    end

    trait :non_conflicting do
      start_time { 3.hours.from_now }
      end_time { 4.hours.from_now }
    end
  end
end
