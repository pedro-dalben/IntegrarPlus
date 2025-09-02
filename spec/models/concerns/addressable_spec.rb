# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Addressable, type: :concern do
  let(:professional) { create(:professional) }

  describe 'associations' do
    it 'has many addresses' do
      expect(professional).to respond_to(:addresses)
    end

    it 'has one primary address' do
      expect(professional).to respond_to(:primary_address)
    end

    it 'has one secondary address' do
      expect(professional).to respond_to(:secondary_address)
    end
  end

  describe '#address_by_type' do
    let!(:primary_address) { create(:address, addressable: professional, address_type: 'primary') }
    let!(:secondary_address) { create(:address, addressable: professional, address_type: 'secondary') }

    it 'returns address by type' do
      expect(professional.address_by_type('primary')).to eq(primary_address)
      expect(professional.address_by_type('secondary')).to eq(secondary_address)
    end

    it 'returns nil for non-existent type' do
      expect(professional.address_by_type('billing')).to be_nil
    end
  end

  describe '#has_address?' do
    context 'with primary address' do
      let!(:primary_address) { create(:address, addressable: professional, address_type: 'primary') }

      it 'returns true for existing address type' do
        expect(professional.has_address?('primary')).to be true
      end

      it 'returns false for non-existing address type' do
        expect(professional.has_address?('secondary')).to be false
      end

      it 'defaults to primary type' do
        expect(professional.has_address?).to be true
      end
    end

    context 'without addresses' do
      it 'returns false' do
        expect(professional.has_address?).to be false
      end
    end
  end

  describe '#full_address' do
    let!(:primary_address) { create(:address, addressable: professional, address_type: 'primary') }

    it 'returns full address for specified type' do
      expect(professional.full_address('primary')).to eq(primary_address.full_address)
    end

    it 'defaults to primary type' do
      expect(professional.full_address).to eq(primary_address.full_address)
    end

    it 'returns empty string for non-existent type' do
      expect(professional.full_address('secondary')).to eq('')
    end
  end

  describe '#complete_address?' do
    let!(:complete_address) { create(:address, addressable: professional, address_type: 'primary') }

    it 'returns true for complete address' do
      expect(professional.complete_address?('primary')).to be true
    end

    it 'defaults to primary type' do
      expect(professional.complete_address?).to be true
    end

    it 'returns false for non-existent type' do
      expect(professional.complete_address?('secondary')).to be false
    end
  end

  describe '#create_address_from_cep' do
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

    context 'without existing address' do
      it 'creates new address' do
        expect do
          professional.create_address_from_cep(cep_data)
        end.to change(professional.addresses, :count).by(1)

        address = professional.primary_address
        expect(address.zip_code).to eq('01310-100')
        expect(address.street).to eq('Avenida Paulista')
      end
    end

    context 'with existing address' do
      let!(:existing_address) { create(:address, addressable: professional, address_type: 'primary') }

      it 'updates existing address' do
        expect do
          professional.create_address_from_cep(cep_data)
        end.not_to change(professional.addresses, :count)

        existing_address.reload
        expect(existing_address.zip_code).to eq('01310-100')
        expect(existing_address.street).to eq('Avenida Paulista')
      end
    end

    it 'allows custom address type' do
      professional.create_address_from_cep(cep_data, type: 'secondary')
      expect(professional.secondary_address).to be_present
      expect(professional.secondary_address.zip_code).to eq('01310-100')
    end

    it 'accepts additional fields' do
      professional.create_address_from_cep(cep_data, number: '123', complement: 'Apt 45')
      address = professional.primary_address
      expect(address.number).to eq('123')
      expect(address.complement).to eq('Apt 45')
    end
  end

  describe 'delegated methods' do
    let!(:primary_address) do
      create(:address,
             addressable: professional,
             address_type: 'primary',
             zip_code: '01310-100',
             street: 'Avenida Paulista',
             neighborhood: 'Bela Vista',
             city: 'São Paulo',
             state: 'SP',
             latitude: -23.5505,
             longitude: -46.6333)
    end

    it 'delegates zip_code to primary address' do
      expect(professional.zip_code).to eq('01310-100')
    end

    it 'delegates street to primary address' do
      expect(professional.street).to eq('Avenida Paulista')
    end

    it 'delegates neighborhood to primary address' do
      expect(professional.neighborhood).to eq('Bela Vista')
    end

    it 'delegates city to primary address' do
      expect(professional.city).to eq('São Paulo')
    end

    it 'delegates state to primary address' do
      expect(professional.state).to eq('SP')
    end

    it 'delegates coordinates to primary address' do
      coordinates = professional.coordinates
      expect(coordinates[:latitude]).to eq(-23.5505)
      expect(coordinates[:longitude]).to eq(-46.6333)
    end

    context 'without primary address' do
      let(:professional_without_address) { create(:professional) }

      it 'returns nil for delegated methods' do
        expect(professional_without_address.zip_code).to be_nil
        expect(professional_without_address.street).to be_nil
        expect(professional_without_address.coordinates).to be_nil
      end
    end
  end

  describe 'legacy compatibility methods' do
    let!(:primary_address) { create(:address, addressable: professional, address_type: 'primary') }

    it 'provides endereco_completo method' do
      expect(professional.endereco_completo).to eq(professional.full_address)
    end

    it 'provides endereco_completo? method' do
      expect(professional.endereco_completo?).to eq(professional.complete_address?)
    end
  end
end
