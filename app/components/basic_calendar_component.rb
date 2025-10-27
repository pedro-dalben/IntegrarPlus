# frozen_string_literal: true

class BasicCalendarComponent < ViewComponent::Base
  include EventsHelper

  def initialize(events: [], professional: nil, read_only: false)
    @events = events
    @professional = professional
    @read_only = read_only
  end

  private

  attr_reader :events, :professional, :read_only

  def calendar_id
    if professional
      "basic-calendar-professional-#{professional.id}"
    else
      'basic-calendar-main'
    end
  end

  def events_data
    return [] if events.empty?

    events.map do |event|
      # Se o evento tem um medical_appointment associado, usar suas informações
      if event.respond_to?(:medical_appointment) && event.medical_appointment.present?
        appointment = event.medical_appointment

        patient_name = if appointment.anamnesis&.portal_intake.present?
                         appointment.anamnesis.portal_intake.beneficiary_name
                       elsif appointment.patient.present?
                         appointment.patient.name
                       else
                         'Paciente não informado'
                       end

        appointment_type_label = I18n.t("admin.medical_appointments.appointment_types.#{appointment.appointment_type}",
                                         default: appointment.appointment_type.humanize)

        title = "#{appointment_type_label} - #{patient_name}"
        description = appointment.notes || event.description || ''
      else
        title = event.title
        description = event.description || ''
      end

      {
        id: event.id,
        title: title,
        start: event.start_time,
        end: event.end_time,
        start_time: event.start_time&.strftime('%H:%M'),
        end_time: event.end_time&.strftime('%H:%M'),
        color: event_color(event.event_type),
        professional_name: event.professional&.full_name || 'N/A',
        event_type: event.event_type,
        description: description
      }
    end
  end

  def event_types
    Event.event_types.keys.map do |type|
      {
        value: type,
        label: type.humanize,
        color: event_color(type)
      }
    end
  end

  def current_month_events
    events_data.select do |event|
      event[:start].month == Date.current.month &&
        event[:start].year == Date.current.year
    end
  end

  def events_for_day(day)
    current_month_events.select do |event|
      event[:start].day == day
    end
  end

  def calendar_days
    start_date = Date.current.beginning_of_month
    end_date = Date.current.end_of_month
    start_date..end_date
  end
end
