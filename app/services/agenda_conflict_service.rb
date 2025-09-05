class AgendaConflictService
  def self.check_conflicts(agenda, professional, start_time, end_time)
    conflicts = []

    conflicts += check_agenda_conflicts(agenda, professional, start_time, end_time)
    conflicts += check_event_conflicts(professional, start_time, end_time)
    conflicts += check_holiday_conflicts(start_time, end_time)
    conflicts += check_professional_availability(professional, start_time, end_time)

    conflicts
  end

  def self.check_agenda_conflicts(agenda, professional, start_time, end_time)
    conflicts = []

    other_agendas = professional.agendas.active.where.not(id: agenda.id)

    other_agendas.each do |other_agenda|
      if schedules_overlap?(other_agenda, start_time, end_time)
        conflicts << {
          type: :agenda_conflict,
          message: "Conflito com agenda '#{other_agenda.name}'",
          conflicting_agenda: other_agenda,
          severity: :high
        }
      end
    end

    conflicts
  end

  def self.check_event_conflicts(professional, start_time, end_time)
    conflicts = []

    conflicting_events = Event.available_slots(professional.id, start_time, end_time)

    conflicting_events.each do |event|
      conflicts << {
        type: :event_conflict,
        message: "Conflito com evento '#{event.title}'",
        conflicting_event: event,
        severity: :high
      }
    end

    conflicts
  end

  def self.check_holiday_conflicts(start_time, end_time)
    conflicts = []

    if start_time.to_date == end_time.to_date
      date = start_time.to_date

      if holiday?(date)
        conflicts << {
          type: :holiday_conflict,
          message: "Data #{date.strftime('%d/%m/%Y')} é um feriado",
          date: date,
          severity: :medium
        }
      end
    end

    conflicts
  end

  def self.check_professional_availability(professional, start_time, end_time)
    conflicts = []

    unless professional.available_at?(start_time, end_time)
      conflicts << {
        type: :availability_conflict,
        message: "Profissional não disponível neste horário",
        professional: professional,
        severity: :high
      }
    end

    conflicts
  end

  def self.schedules_overlap?(agenda, start_time, end_time)
    return false unless agenda.working_hours.present?

    target_wday = start_time.wday
    day_config = agenda.working_hours['weekdays']&.find { |d| d['wday'] == target_wday }
    return false unless day_config&.dig('periods').present?

    day_config['periods'].any? do |period|
      period_start = Time.parse("#{start_time.to_date} #{period['start']}")
      period_end = Time.parse("#{start_time.to_date} #{period['end']}")

      start_time < period_end && end_time > period_start
    end
  end

  def self.holiday?(date)
    holidays = [
      Date.new(date.year, 1, 1),   # Ano Novo
      Date.new(date.year, 4, 21),  # Tiradentes
      Date.new(date.year, 5, 1),   # Dia do Trabalhador
      Date.new(date.year, 9, 7),   # Independência
      Date.new(date.year, 10, 12), # Nossa Senhora Aparecida
      Date.new(date.year, 11, 2),  # Finados
      Date.new(date.year, 11, 15), # Proclamação da República
      Date.new(date.year, 12, 25)  # Natal
    ]

    holidays.include?(date)
  end

  def self.resolve_conflicts(conflicts, resolution_strategy = :manual)
    case resolution_strategy
    when :auto_resolve
      auto_resolve_conflicts(conflicts)
    when :suggest_alternatives
      suggest_alternative_times(conflicts)
    else
      conflicts
    end
  end

  private

  def self.auto_resolve_conflicts(conflicts)
    resolved_conflicts = []

    conflicts.each do |conflict|
      case conflict[:type]
      when :holiday_conflict
        next
      when :event_conflict
        if conflict[:conflicting_event].can_be_rescheduled?
          conflict[:conflicting_event].reschedule!
          resolved_conflicts << conflict.merge(resolved: true, action: 'Evento reagendado automaticamente')
        else
          resolved_conflicts << conflict
        end
      else
        resolved_conflicts << conflict
      end
    end

    resolved_conflicts
  end

  def self.suggest_alternative_times(conflicts)
    return [] if conflicts.empty?

    professional = conflicts.first[:professional] || conflicts.first[:conflicting_event]&.professional
    return [] unless professional

    original_start = conflicts.first[:start_time]
    original_end = conflicts.first[:end_time]

    alternatives = []

    (1..7).each do |day_offset|
      alternative_date = original_start.to_date + day_offset.days
      next if holiday?(alternative_date)

      alternative_start = Time.parse("#{alternative_date} #{original_start.strftime('%H:%M')}")
      alternative_end = Time.parse("#{alternative_date} #{original_end.strftime('%H:%M')}")

      alternative_conflicts = check_conflicts(nil, professional, alternative_start, alternative_end)

      if alternative_conflicts.empty?
        alternatives << {
          start_time: alternative_start,
          end_time: alternative_end,
          date: alternative_date,
          conflicts: []
        }
      end

      break if alternatives.size >= 3
    end

    alternatives
  end
end
