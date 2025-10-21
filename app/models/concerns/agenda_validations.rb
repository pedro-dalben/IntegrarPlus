# frozen_string_literal: true

# Módulo para validações avançadas de agendas
module AgendaValidations
  extend ActiveSupport::Concern

  included do
    validate :working_hours_format
    validate :no_overlapping_schedules
    validate :professional_availability
    validate :slot_duration_consistency
    validate :buffer_time_validation
  end

  private

  def working_hours_format
    return if working_hours.blank?
    return unless working_hours.is_a?(Hash)

    working_hours['weekdays']&.each do |day_config|
      next if day_config['periods'].blank?

      day_config['periods'].each do |period|
        next if valid_time_range?(period['start'], period['end'])

        errors.add(:working_hours, "Horários inválidos para #{day_name(day_config['wday'])}")
      end
    end
  end

  def no_overlapping_schedules
    return if working_hours.blank?
    return unless working_hours.is_a?(Hash)

    working_hours['weekdays']&.each do |day_config|
      next if day_config['periods'].blank?

      periods = day_config['periods']
      periods.each_with_index do |period, index|
        periods[(index + 1)..].each do |other_period|
          next unless time_ranges_overlap?(period, other_period)

          errors.add(:working_hours, "Sobreposição de horários detectada em #{day_name(day_config['wday'])}")
          return
        end
      end
    end
  end

  def professional_availability
    return if professionals.blank?

    professionals.each do |_professional|
      # Skip validation for now to avoid User/Professional confusion
      next
    end
  end

  def slot_duration_consistency
    return if working_hours.blank? || slot_duration_minutes.blank?
    return unless working_hours.is_a?(Hash)

    working_hours['weekdays']&.each do |day_config|
      next if day_config['periods'].blank?

      day_config['periods'].each do |period|
        period_duration = time_difference_minutes(period['start'], period['end'])
        next unless period_duration < slot_duration_minutes

        errors.add(:slot_duration_minutes,
                   "Duração do slot maior que período disponível em #{day_name(day_config['wday'])}")
      end
    end
  end

  def buffer_time_validation
    return if buffer_minutes.blank? || slot_duration_minutes.blank?

    return unless buffer_minutes >= slot_duration_minutes

    errors.add(:buffer_minutes, 'Tempo de buffer deve ser menor que duração do slot')

    return unless buffer_minutes > 30

    errors.add(:buffer_minutes, 'Tempo de buffer não deve exceder 30 minutos')
  end

  def valid_time_range?(start_time, end_time)
    return false if start_time.blank? || end_time.blank?

    start = Time.zone.parse(start_time)
    finish = Time.zone.parse(end_time)
    start < finish
  rescue ArgumentError
    false
  end

  def time_ranges_overlap?(period1, period2)
    start1 = Time.zone.parse(period1['start'])
    end1 = Time.zone.parse(period1['end'])
    start2 = Time.zone.parse(period2['start'])
    end2 = Time.zone.parse(period2['end'])

    start1 < end2 && start2 < end1
  end

  def conflicting_schedules?(other_agenda)
    return false if other_agenda.working_hours.blank?

    working_hours['weekdays']&.each do |day_config|
      other_day = other_agenda.working_hours['weekdays']&.find { |d| d['wday'] == day_config['wday'] }
      next if other_day&.dig('periods').blank?

      day_config['periods']&.each do |period|
        other_day['periods'].each do |other_period|
          return true if time_ranges_overlap?(period, other_period)
        end
      end
    end

    false
  end

  def time_difference_minutes(start_time, end_time)
    start = Time.zone.parse(start_time)
    finish = Time.zone.parse(end_time)
    ((finish - start) / 1.minute).to_i
  end

  def day_name(wday)
    %w[Domingo Segunda Terça Quarta Quinta Sexta Sábado][wday]
  end
end
