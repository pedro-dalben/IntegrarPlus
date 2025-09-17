require 'rails_helper'

RSpec.describe AvailabilityConfigurationService do
  before do
    allow_any_instance_of(Agenda).to receive(:validate_professionals_present)
  end

  let!(:professional) { create(:professional) }
  let!(:agenda) { create(:agenda, :draft) }

  before do
    professional.professional_availabilities.destroy_all
    professional.availability_exceptions.destroy_all
  end
  let(:service) { described_class.new(professional, agenda) }

  describe '#apply_template' do
    context 'with standard_business_hours template' do
      it 'applies standard business hours schedule' do
        result = service.apply_template('standard_business_hours')

        expect(result[:success]).to be true
        expect(professional.professional_availabilities.count).to eq(10) # Monday to Friday, 2 periods each
        expect(professional.professional_availabilities.where(day_of_week: :monday).count).to eq(2) # Two periods
      end
    end

    context 'with extended_hours template' do
      it 'applies extended hours schedule' do
        result = service.apply_template('extended_hours')

        expect(result[:success]).to be true
        expect(professional.professional_availabilities.count).to eq(5) # Monday to Friday, 1 period each
        expect(professional.professional_availabilities.where(day_of_week: :monday).count).to eq(1) # One period
      end
    end

    context 'with weekend_coverage template' do
      it 'applies weekend coverage schedule' do
        result = service.apply_template('weekend_coverage')

        expect(result[:success]).to be true
        expect(professional.professional_availabilities.count).to eq(7) # All days, 1 period each
        expect(professional.professional_availabilities.where(day_of_week: :saturday).count).to eq(1)
        expect(professional.professional_availabilities.where(day_of_week: :sunday).count).to eq(1)
      end
    end

    context 'with invalid template' do
      it 'returns error for invalid template' do
        result = service.apply_template('invalid_template')

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Template não encontrado')
      end
    end
  end

  describe '#set_custom_schedule' do
    let(:schedule_data) do
      [
        {
          day_of_week: 1,
          enabled: true,
          periods: [
            { start_time: '08:00', end_time: '12:00' },
            { start_time: '13:00', end_time: '17:00' }
          ]
        },
        {
          day_of_week: 2,
          enabled: true,
          periods: [
            { start_time: '09:00', end_time: '18:00' }
          ]
        }
      ]
    end

    it 'creates availabilities from schedule data' do
      result = service.set_custom_schedule(schedule_data)

      expect(result[:success]).to be true
      expect(professional.professional_availabilities.count).to eq(3) # 2 periods for Monday + 1 for Tuesday
    end

    it 'clears existing availabilities before setting new ones' do
      create(:professional_availability, professional: professional, agenda: agenda)

      result = service.set_custom_schedule(schedule_data)

      expect(result[:success]).to be true
      expect(professional.professional_availabilities.where(agenda: agenda).count).to eq(3)
    end

    context 'with invalid schedule data' do
      it 'returns error for invalid data' do
        result = service.set_custom_schedule([])

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Dados de horário inválidos')
      end
    end
  end

  describe '#add_exception' do
    let(:exception_data) do
      {
        exception_date: Date.current + 1.day,
        exception_type: 'unavailable',
        reason: 'Feriado'
      }
    end

    it 'creates availability exception' do
      result = service.add_exception(exception_data)

      expect(result[:success]).to be true
      expect(professional.availability_exceptions.count).to eq(1)
      expect(professional.availability_exceptions.first.reason).to eq('Feriado')
    end

    context 'with different_hours exception' do
      let(:exception_data) do
        {
          exception_date: Date.current + 1.day,
          exception_type: 'different_hours',
          start_time: '10:00',
          end_time: '14:00',
          reason: 'Horário reduzido'
        }
      end

      it 'creates exception with time range' do
        result = service.add_exception(exception_data)

        expect(result[:success]).to be true
        exception = professional.availability_exceptions.first
        expect(exception.start_time.strftime('%H:%M')).to eq('10:00')
        expect(exception.end_time.strftime('%H:%M')).to eq('14:00')
      end
    end
  end

  describe '#get_availability_for_date' do
    let(:date) { Date.current }

    before do
      create(:professional_availability,
             professional: professional,
             agenda: agenda,
             day_of_week: date.wday,
             start_time: '08:00',
             end_time: '17:00')
    end

    it 'returns availability data for specific date' do
      result = service.get_availability_for_date(date)

      expect(result[:date]).to eq(date)
      expect(result[:availabilities].count).to eq(1)
      expect(result[:is_available]).to be true
    end
  end

  describe '#get_weekly_schedule' do
    before do
      create(:professional_availability,
             professional: professional,
             agenda: agenda,
             day_of_week: :monday,
             start_time: '08:00',
             end_time: '17:00')
    end

    it 'returns weekly schedule data' do
      # Create a specific availability for Monday to test
      professional.professional_availabilities.create!(
        agenda: agenda,
        day_of_week: :monday,
        start_time: '08:00',
        end_time: '17:00',
        active: true
      )

      result = service.get_weekly_schedule

      expect(result.length).to eq(7)
      expect(result[1][:day_name]).to eq('Monday')
      expect(result[1][:is_available]).to be true # Monday has availability
      expect(result[0][:is_available]).to be false # Sunday has no availability
    end
  end
end
