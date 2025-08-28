# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address, type: :model do
  let(:professional) { create(:professional) }

  describe 'associations' do
    it { should belong_to(:addressable) }
  end

  describe 'validations' do
    subject { build(:address, addressable: professional) }

    it { should validate_presence_of(:zip_code) }
    it { should validate_presence_of(:street) }
    it { should validate_presence_of(:neighborhood) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:address_type) }

    it 'validates ZIP code format' do
      address = build(:address, addressable: professional, zip_code: '12345')
      expect(address).not_to be_valid
      expect(address.errors[:zip_code]).to include('must have format 00000-000')
    end

    it 'validates state inclusion' do
      address = build(:address, addressable: professional, state: 'XX')
      expect(address).not_to be_valid
      expect(address.errors[:state]).to include('must be a valid Brazilian state')
    end

    it 'validates address_type inclusion' do
      address = build(:address, addressable: professional, address_type: 'invalid')
      expect(address).not_to be_valid
      expect(address.errors[:address_type]).to include('must be a valid address type')
    end
  end

  describe 'scopes' do
    let!(:primary_address) { create(:address, addressable: professional, address_type: 'primary') }
    let!(:secondary_address) { create(:address, addressable: professional, address_type: 'secondary') }

    it 'filters by primary type' do
      expect(Address.primary).to include(primary_address)
      expect(Address.primary).not_to include(secondary_address)
    end

    it 'filters by secondary type' do
      expect(Address.secondary).to include(secondary_address)
      expect(Address.secondary).not_to include(primary_address)
    end

    it 'filters by specific type' do
      expect(Address.by_type('primary')).to include(primary_address)
      expect(Address.by_type('secondary')).to include(secondary_address)
    end
  end

  describe '#full_address' do
    let(:address) { build(:address, addressable: professional) }

    it 'returns formatted address' do
      expected = "#{address.street}, #{address.neighborhood}, #{address.city}/#{address.state}, ZIP: #{address.zip_code}"
      expect(address.full_address).to eq(expected)
    end

    it 'returns empty string when required fields are blank' do
      address = build(:address, addressable: professional, street: '', neighborhood: '', city: '', state: '')
      expect(address.full_address).to eq('')
    end
  end

  describe '#complete?' do
    it 'returns true when all required fields are present' do
      address = build(:address, addressable: professional)
      expect(address.complete?).to be true
    end

    it 'returns false when any required field is missing' do
      address = build(:address, addressable: professional, street: '')
      expect(address.complete?).to be false
    end
  end

  describe '#coordinates_present?' do
    it 'returns true when both coordinates are present' do
      address = build(:address, addressable: professional, latitude: -23.5505, longitude: -46.6333)
      expect(address.coordinates_present?).to be true
    end

    it 'returns false when coordinates are missing' do
      address = build(:address, addressable: professional, latitude: nil, longitude: nil)
      expect(address.coordinates_present?).to be false
    end
  end

  describe '.create_from_cep_data' do
    let(:cep_data) do
      {
        zip_code: '01310-100',
        street: 'Avenida Paulista',
        neighborhood: 'Bela Vista',
        city: 'São Paulo',
        state: 'SP',
        coordinates: {
          latitude: -23.5505,
          longitude: -46.6333
        }
      }
    end

    it 'creates address from CEP service data' do
      address = Address.create_from_cep_data(professional, cep_data)

      expect(address).to be_persisted
      expect(address.zip_code).to eq('01310-100')
      expect(address.street).to eq('Avenida Paulista')
      expect(address.neighborhood).to eq('Bela Vista')
      expect(address.city).to eq('São Paulo')
      expect(address.state).to eq('SP')
      expect(address.latitude).to eq(-23.5505)
      expect(address.longitude).to eq(-46.6333)
      expect(address.address_type).to eq('primary')
    end

    it 'allows custom address type' do
      address = Address.create_from_cep_data(professional, cep_data, address_type: 'secondary')
      expect(address.address_type).to eq('secondary')
    end
  end
end
