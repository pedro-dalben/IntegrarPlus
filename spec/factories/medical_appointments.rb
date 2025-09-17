FactoryBot.define do
  factory :medical_appointment do
    scheduled_at { 1.hour.from_now }
    duration_minutes { 50 }
    appointment_type { :initial_consultation }
    status { :scheduled }
    professional { create(:professional) }
    patient { create(:user) }
    agenda { create(:agenda, :draft) }

    trait :anamnese do
      appointment_type { :anamnese }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :completed do
      status { :completed }
    end

    trait :no_show do
      status { :no_show }
    end
  end
end
