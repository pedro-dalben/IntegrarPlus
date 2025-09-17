FactoryBot.define do
  factory :agenda do
    sequence(:name) { |n| "Agenda #{n}" }
    service_type { :anamnese }
    default_visibility { :restricted }
    slot_duration_minutes { 50 }
    buffer_minutes { 10 }
    color_theme { '#3B82F6' }
    status { :active }
    working_hours do
      {
        'slot_duration' => 50,
        'buffer' => 10,
        'weekdays' => [
          {
            'wday' => 1,
            'periods' => [
              { 'start' => '08:00', 'end' => '12:00' },
              { 'start' => '13:00', 'end' => '17:00' }
            ]
          }
        ],
        'exceptions' => []
      }
    end

    association :created_by, factory: :user
    association :updated_by, factory: :user
    association :unit, factory: :unit

    trait :draft do
      status { :draft }
    end

    trait :archived do
      status { :archived }
    end
  end
end
