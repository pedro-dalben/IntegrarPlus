# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppointmentSchedulingService do
  let(:professional) { create(:professional) }
  let(:agenda) { create(:agenda, :draft) }

  before do
    allow_any_instance_of(Agenda).to receive(:validate_professionals_present)
  end
  let(:service) { described_class.new(professional, agenda) }

  describe '#schedule_appointment' do
    let(:appointment_data) do
      {
        scheduled_datetime: DateTime.current + 1.day,
        appointment_type: 'initial_consultation',
        title: 'Consulta de Teste',
        description: 'Descrição da consulta',
        notes: 'Notas da consulta'
      }
    end

    it 'creates event and medical appointment' do
      result = service.schedule_appointment(appointment_data)

      expect(result[:success]).to be true
      expect(Event.count).to eq(1)
      expect(MedicalAppointment.count).to eq(1)

      event = result[:event]
      appointment = result[:medical_appointment]

      expect(event.title).to eq('Consulta de Teste')
      expect(event.event_type).to eq('consulta')
      expect(appointment.appointment_type).to eq('initial_consultation')
      expect(appointment.event).to eq(event)
    end

    context 'when time slot is not available' do
      before do
        create(:event,
               professional: professional,
               created_by: professional,
               start_time: appointment_data[:scheduled_datetime],
               end_time: appointment_data[:scheduled_datetime] + 1.hour)
      end

      it 'returns error for unavailable time slot' do
        result = service.schedule_appointment(appointment_data)

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Horário não disponível')
        expect(result[:conflicts]).to be_present
      end
    end

    context 'with invalid appointment data' do
      it 'returns error for invalid data' do
        result = service.schedule_appointment({})

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Dados de agendamento inválidos')
      end
    end
  end

  describe '#check_availability' do
    let(:datetime) { DateTime.current + 1.day }
    let(:duration_minutes) { 60 }

    context 'when time slot is available' do
      it 'returns available status' do
        result = service.check_availability(datetime, duration_minutes)

        expect(result[:available]).to be true
        expect(result[:conflicts]).to be_empty
      end
    end

    context 'when time slot has conflicts' do
      before do
        create(:event,
               professional: professional,
               created_by: professional,
               start_time: datetime,
               end_time: datetime + 1.hour)
      end

      it 'returns unavailable status with conflicts' do
        result = service.check_availability(datetime, duration_minutes)

        expect(result[:available]).to be false
        expect(result[:conflicts]).not_to be_empty
        expect(result[:conflicts].first[:type]).to eq('event')
      end
    end
  end

  describe '#get_available_slots' do
    let(:date) { Date.current + 1.day }
    let(:duration_minutes) { 60 }

    before do
      create(:professional_availability,
             professional: professional,
             agenda: agenda,
             day_of_week: date.wday,
             start_time: '08:00',
             end_time: '17:00')
    end

    it 'returns available time slots for date' do
      slots = service.get_available_slots(date, duration_minutes)

      expect(slots).not_to be_empty
      expect(slots.first[:start_time].to_date).to eq(date)
      expect(slots.first[:available]).to be true
    end
  end

  describe '#reschedule_appointment' do
    let(:appointment) { create(:medical_appointment, professional: professional, agenda: agenda) }
    let(:new_datetime) { DateTime.current + 2.days }
    let(:new_duration) { 90 }

    it 'reschedules appointment successfully' do
      result = service.reschedule_appointment(appointment, new_datetime, new_duration)

      expect(result[:success]).to be true
      appointment.reload
      expect(appointment.scheduled_at.to_i).to eq(new_datetime.to_i)
      expect(appointment.duration_minutes).to eq(new_duration)
      expect(appointment.status).to eq('rescheduled')
    end

    context 'when new time slot is not available' do
      before do
        create(:event,
               professional: professional,
               created_by: professional,
               start_time: new_datetime,
               end_time: new_datetime + 1.hour)
      end

      it 'returns error for unavailable time slot' do
        result = service.reschedule_appointment(appointment, new_datetime, new_duration)

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Novo horário não disponível')
      end
    end
  end

  describe '#cancel_appointment' do
    let(:appointment) { create(:medical_appointment, professional: professional, agenda: agenda) }

    it 'cancels appointment successfully' do
      result = service.cancel_appointment(appointment, 'Cancelado pelo paciente')

      expect(result[:success]).to be true
      appointment.reload
      expect(appointment.status).to eq('cancelled')
    end

    context 'when appointment cannot be cancelled' do
      before do
        appointment.update!(scheduled_at: 1.hour.ago)
      end

      it 'returns error for non-cancellable appointment' do
        result = service.cancel_appointment(appointment)

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Agendamento não pode ser cancelado')
      end
    end
  end
end
