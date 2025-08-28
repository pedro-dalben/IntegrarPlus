# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    association :addressable, factory: :professional
    address_type { 'primary' }
    zip_code { '01310-100' }
    street { 'Avenida Paulista' }
    number { '1000' }
    complement { 'Conjunto 101' }
    neighborhood { 'Bela Vista' }
    city { 'São Paulo' }
    state { 'SP' }
    latitude { -23.5505 }
    longitude { -46.6333 }

    trait :secondary do
      address_type { 'secondary' }
    end

    trait :billing do
      address_type { 'billing' }
    end

    trait :shipping do
      address_type { 'shipping' }
    end

    trait :without_coordinates do
      latitude { nil }
      longitude { nil }
    end

    trait :incomplete do
      street { '' }
      neighborhood { '' }
    end

    # Different locations
    trait :rio_de_janeiro do
      zip_code { '20040-020' }
      street { 'Avenida Atlântica' }
      neighborhood { 'Copacabana' }
      city { 'Rio de Janeiro' }
      state { 'RJ' }
      latitude { -22.9068 }
      longitude { -43.1729 }
    end

    trait :belo_horizonte do
      zip_code { '30112-000' }
      street { 'Avenida Afonso Pena' }
      neighborhood { 'Centro' }
      city { 'Belo Horizonte' }
      state { 'MG' }
      latitude { -19.9167 }
      longitude { -43.9345 }
    end
  end
end
