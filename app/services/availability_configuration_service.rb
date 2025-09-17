class AvailabilityConfigurationService
  def initialize(professional, agenda = nil)
    @professional = professional
    @agenda = agenda
  end

  def apply_template(template_id)
    case template_id
    when 'standard_business_hours'
      apply_standard_business_hours
    when 'extended_hours'
      apply_extended_hours
    when 'weekend_coverage'
      apply_weekend_coverage
    else
      { success: false, error: 'Template não encontrado' }
    end
  end

  def set_custom_schedule(schedule_data)
    return { success: false, error: 'Dados de horário inválidos' } unless valid_schedule_data?(schedule_data)

    ActiveRecord::Base.transaction do
      clear_existing_availabilities

      schedule_data.each do |day_data|
        next unless day_data[:enabled]

        day_data[:periods].each do |period|
          create_availability(
            day_of_week: day_data[:day_of_week],
            start_time: period[:start_time],
            end_time: period[:end_time],
            notes: period[:notes]
          )
        end
      end

      { success: true, message: 'Horários configurados com sucesso' }
    end
  rescue StandardError => e
    { success: false, error: e.message }
  end

  def add_exception(exception_data)
    return { success: false, error: 'Dados de exceção inválidos' } unless valid_exception_data?(exception_data)

    exception = @professional.availability_exceptions.create!(
      agenda: @agenda,
      exception_date: exception_data[:exception_date],
      exception_type: exception_data[:exception_type],
      start_time: exception_data[:start_time],
      end_time: exception_data[:end_time],
      reason: exception_data[:reason]
    )

    { success: true, exception: exception }
  rescue StandardError => e
    { success: false, error: e.message }
  end

  def get_availability_for_date(date)
    weekday = date.wday
    availabilities = @professional.professional_availabilities
                                  .where(agenda: @agenda)
                                  .for_day(weekday)
                                  .active

    exceptions = @professional.availability_exceptions
                              .where(agenda: @agenda)
                              .for_date(date)
                              .active

    {
      date: date,
      availabilities: availabilities,
      exceptions: exceptions,
      is_available: check_availability_for_date(date, availabilities, exceptions)
    }
  end

  def get_weekly_schedule
    (0..6).map do |day_of_week|
      day_name = Date::DAYNAMES[day_of_week]
      # Map Date::DAYNAMES index to ProfessionalAvailability enum
      # Date::DAYNAMES: [Sunday(0), Monday(1), Tuesday(2), Wednesday(3), Thursday(4), Friday(5), Saturday(6)]
      # ProfessionalAvailability: [monday(0), tuesday(1), wednesday(2), thursday(3), friday(4), saturday(5), sunday(6)]
      enum_mapping = { 0 => 'sunday', 1 => 'monday', 2 => 'tuesday', 3 => 'wednesday', 4 => 'thursday', 5 => 'friday',
                       6 => 'saturday' }
      day_enum = enum_mapping[day_of_week]

      availabilities = @professional.professional_availabilities
                                    .where(agenda: @agenda)
                                    .for_day(day_enum)
                                    .active

      {
        day_of_week: day_of_week,
        day_name: day_name,
        availabilities: availabilities,
        is_available: availabilities.any?
      }
    end
  end

  private

  def apply_standard_business_hours
    schedule_data = [
      { day_of_week: 0, enabled: true,
        periods: [{ start_time: '08:00', end_time: '12:00' }, { start_time: '13:00', end_time: '17:00' }] },
      { day_of_week: 1, enabled: true,
        periods: [{ start_time: '08:00', end_time: '12:00' }, { start_time: '13:00', end_time: '17:00' }] },
      { day_of_week: 2, enabled: true,
        periods: [{ start_time: '08:00', end_time: '12:00' }, { start_time: '13:00', end_time: '17:00' }] },
      { day_of_week: 3, enabled: true,
        periods: [{ start_time: '08:00', end_time: '12:00' }, { start_time: '13:00', end_time: '17:00' }] },
      { day_of_week: 4, enabled: true,
        periods: [{ start_time: '08:00', end_time: '12:00' }, { start_time: '13:00', end_time: '17:00' }] }
    ]

    set_custom_schedule(schedule_data)
  end

  def apply_extended_hours
    schedule_data = [
      { day_of_week: 0, enabled: true, periods: [{ start_time: '07:00', end_time: '19:00' }] },
      { day_of_week: 1, enabled: true, periods: [{ start_time: '07:00', end_time: '19:00' }] },
      { day_of_week: 2, enabled: true, periods: [{ start_time: '07:00', end_time: '19:00' }] },
      { day_of_week: 3, enabled: true, periods: [{ start_time: '07:00', end_time: '19:00' }] },
      { day_of_week: 4, enabled: true, periods: [{ start_time: '07:00', end_time: '19:00' }] }
    ]

    set_custom_schedule(schedule_data)
  end

  def apply_weekend_coverage
    schedule_data = [
      { day_of_week: 0, enabled: true, periods: [{ start_time: '08:00', end_time: '17:00' }] },
      { day_of_week: 1, enabled: true, periods: [{ start_time: '08:00', end_time: '17:00' }] },
      { day_of_week: 2, enabled: true, periods: [{ start_time: '08:00', end_time: '17:00' }] },
      { day_of_week: 3, enabled: true, periods: [{ start_time: '08:00', end_time: '17:00' }] },
      { day_of_week: 4, enabled: true, periods: [{ start_time: '08:00', end_time: '17:00' }] },
      { day_of_week: 5, enabled: true, periods: [{ start_time: '09:00', end_time: '13:00' }] },
      { day_of_week: 6, enabled: true, periods: [{ start_time: '09:00', end_time: '13:00' }] }
    ]

    set_custom_schedule(schedule_data)
  end

  def create_availability(day_of_week:, start_time:, end_time:, notes: nil)
    @professional.professional_availabilities.create!(
      agenda: @agenda,
      day_of_week: day_of_week,
      start_time: start_time,
      end_time: end_time,
      notes: notes,
      active: true
    )
  end

  def clear_existing_availabilities
    @professional.professional_availabilities
                 .where(agenda: @agenda)
                 .destroy_all
  end

  def valid_schedule_data?(schedule_data)
    return false unless schedule_data.is_a?(Array)
    return false if schedule_data.empty?

    schedule_data.all? do |day_data|
      day_data[:day_of_week].present? &&
        day_data[:periods].is_a?(Array) &&
        day_data[:periods].all? { |period| period[:start_time].present? && period[:end_time].present? }
    end
  end

  def valid_exception_data?(exception_data)
    exception_data[:exception_date].present? &&
      exception_data[:exception_type].present? &&
      (exception_data[:exception_type] == 'unavailable' ||
       (exception_data[:start_time].present? && exception_data[:end_time].present?))
  end

  def check_availability_for_date(date, availabilities, exceptions)
    return false if availabilities.empty?
    return false if exceptions.any?(&:blocks_time?)

    true
  end
end
