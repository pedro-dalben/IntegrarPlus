# frozen_string_literal: true

class AgendaUpdateGuardService
  Impact = Struct.new(:appointment_id, :scheduled_at, :professional_name, :reason, keyword_init: true)

  def initialize(agenda, new_working_hours)
    @agenda = agenda
    @new_working_hours = normalize_working_hours(new_working_hours)
  end

  def impacted_future_appointments(reference_time: Time.current)
    return [] if @new_working_hours.blank? || @new_working_hours['weekdays'].blank?

    future_active = @agenda.medical_appointments
                           .where(scheduled_at: reference_time..)
                           .where.not(status: %w[cancelled no_show])
                           .includes(:professional)

    impacts = []

    future_active.find_each do |appt|
      unless fits_new_schedule?(appt.scheduled_at)
        impacts << Impact.new(
          appointment_id: appt.id,
          scheduled_at: appt.scheduled_at,
          professional_name: appt.professional.respond_to?(:full_name) ? appt.professional.full_name : appt.professional&.name,
          reason: 'Fora do novo horário configurado'
        )
      end
    end

    impacts
  end

  private

  def normalize_working_hours(wh)
    return {} if wh.blank?
    return wh if wh.is_a?(Hash)

    begin
      JSON.parse(wh)
    rescue StandardError
      {}
    end
  end

  def fits_new_schedule?(time)
    wday = time.wday
    day = @new_working_hours['weekdays']&.find { |d| (d['wday'] || d[:wday]) == wday }
    return false if day.nil?

    periods = day['periods'] || day[:periods] || []
    periods.any? do |p|
      start_val = p['start'] || p[:start] || p['start_time'] || p[:start_time]
      end_val = p['end'] || p[:end] || p['end_time'] || p[:end_time]
      next false unless start_val && end_val

      begin
        start_t = Time.zone.parse("#{time.to_date} #{start_val}")
        end_t = Time.zone.parse("#{time.to_date} #{end_val}")
      rescue ArgumentError
        next false
      end
      (time >= start_t) && (time < end_t)
    end
  end
end
