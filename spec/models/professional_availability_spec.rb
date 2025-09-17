require 'rails_helper'

RSpec.describe ProfessionalAvailability, type: :model do
  let(:professional) { create(:professional) }
  let(:agenda) { create(:agenda, :draft) }

  before do
    # Desabilitar validação de profissionais para testes
    allow_any_instance_of(Agenda).to receive(:validate_professionals_present)
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      availability = build(:professional_availability,
                           professional: professional,
                           agenda: agenda,
                           day_of_week: :monday,
                           start_time: '08:00',
                           end_time: '17:00')
      expect(availability).to be_valid
    end

    it 'requires professional' do
      availability = build(:professional_availability, professional: nil)
      expect(availability).not_to be_valid
      expect(availability.errors[:professional]).to include('é obrigatório(a)')
    end

    it 'requires day_of_week' do
      availability = build(:professional_availability, day_of_week: nil)
      expect(availability).not_to be_valid
      expect(availability.errors[:day_of_week]).to include('não pode ficar em branco')
    end

    it 'requires start_time' do
      availability = build(:professional_availability, start_time: nil)
      expect(availability).not_to be_valid
      expect(availability.errors[:start_time]).to include('não pode ficar em branco')
    end

    it 'requires end_time' do
      availability = build(:professional_availability, end_time: nil)
      expect(availability).not_to be_valid
      expect(availability.errors[:end_time]).to include('não pode ficar em branco')
    end

    it 'validates end_time is after start_time' do
      availability = build(:professional_availability,
                           start_time: '17:00',
                           end_time: '08:00')
      expect(availability).not_to be_valid
      expect(availability.errors[:end_time]).to include('deve ser posterior ao horário de início')
    end
  end

  describe 'associations' do
    it 'belongs to professional' do
      availability = create(:professional_availability, professional: professional)
      expect(availability.professional).to eq(professional)
    end

    it 'belongs to agenda' do
      availability = create(:professional_availability, agenda: agenda)
      expect(availability.agenda).to eq(agenda)
    end
  end

  describe 'scopes' do
    let!(:monday_availability) { create(:professional_availability, day_of_week: :monday) }
    let!(:tuesday_availability) { create(:professional_availability, day_of_week: :tuesday) }
    let!(:inactive_availability) { create(:professional_availability, active: false) }

    describe '.for_day' do
      it 'returns availabilities for specific day' do
        expect(ProfessionalAvailability.for_day(:monday)).to include(monday_availability)
        expect(ProfessionalAvailability.for_day(:monday)).not_to include(tuesday_availability)
      end
    end

    describe '.active' do
      it 'returns only active availabilities' do
        expect(ProfessionalAvailability.active).to include(monday_availability, tuesday_availability)
        expect(ProfessionalAvailability.active).not_to include(inactive_availability)
      end
    end
  end

  describe 'methods' do
    let(:availability) do
      create(:professional_availability,
             start_time: '08:00',
             end_time: '17:00')
    end

    describe '#duration_minutes' do
      it 'calculates duration correctly' do
        expect(availability.duration_minutes).to eq(540) # 9 hours * 60 minutes
      end
    end

    describe '#covers_time?' do
      it 'returns true for time within availability' do
        time = Time.parse('2000-01-01 10:00')
        expect(availability.covers_time?(time)).to be true
      end

      it 'returns false for time outside availability' do
        time = Time.parse('2000-01-01 18:00')
        expect(availability.covers_time?(time)).to be false
      end
    end

    describe '#time_slots' do
      it 'generates time slots correctly' do
        slots = availability.time_slots(60, 0) # 1 hour slots, no buffer
        expect(slots.length).to eq(9)
        expect(slots.first[:start_time]).to eq(Time.parse('2000-01-01 08:00'))
        expect(slots.first[:end_time]).to eq(Time.parse('2000-01-01 09:00'))
      end
    end
  end
end
