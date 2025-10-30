# frozen_string_literal: true

class EventAvailabilityService
  def initialize(professional_id)
    @professional_id = professional_id
  end

  def check_availability(start_time, end_time)
    conflicting_events = Event.active_in_time_range(@professional_id, start_time, end_time)

    {
      professional_id: @professional_id,
      start_time: start_time,
      end_time: end_time,
      available: conflicting_events.empty?,
      conflicting_events: conflicting_events.map(&:masked_for_institutional_view),
      available_slots: calculate_available_slots(start_time, end_time)
    }
  end

  def find_available_slots(start_date, end_date, duration_minutes = 60)
    slots = []
    current_time = start_date.beginning_of_day + 8.hours # Começa às 8h

    while current_time < end_date.end_of_day - duration_minutes.minutes
      slot_end = current_time + duration_minutes.minutes

      if slot_end <= end_date.end_of_day
        conflicting_events = Event.active_in_time_range(@professional_id, current_time, slot_end)

        if conflicting_events.empty?
          slots << {
            start_time: current_time,
            end_time: slot_end,
            duration_minutes: duration_minutes
          }
        end
      end

      current_time += 30.minutes # Incrementa de 30 em 30 minutos
    end

    slots
  end

  def get_weekly_schedule(week_start = Date.current.beginning_of_week)
    week_end = week_start.end_of_week

    schedule = {}

    (week_start..week_end).each do |date|
      day_start = date.beginning_of_day + 8.hours
      day_end = date.end_of_day - 1.hour

      schedule[date] = {
        date: date,
        day_name: date.strftime('%A'),
        available_slots: find_available_slots(day_start, day_end),
        events: Event.for_professional(@professional_id)
                     .where(start_time: day_start..day_end)
                     .order(:start_time)
      }
    end

    schedule
  end

  def get_monthly_overview(month = Date.current.beginning_of_month)
    month_end = month.end_of_month

    events = Event.for_professional(@professional_id)
                  .where(start_time: month.beginning_of_day..month_end.end_of_day)
                  .order(:start_time)

    daily_counts = {}
    type_counts = {}

    events.each do |event|
      date = event.start_time.to_date
      daily_counts[date] ||= 0
      daily_counts[date] += 1

      type_counts[event.event_type] ||= 0
      type_counts[event.event_type] += 1
    end

    {
      month: month,
      total_events: events.count,
      daily_counts: daily_counts,
      type_counts: type_counts,
      events: events
    }
  end

  def suggest_optimal_time(duration_minutes, preferred_date = Date.current, preferred_hours = [9, 14, 16])
    date = preferred_date
    attempts = 0
    max_attempts = 14 # Tenta por 2 semanas

    while attempts < max_attempts
      preferred_hours.each do |hour|
        start_time = date.beginning_of_day + hour.hours
        end_time = start_time + duration_minutes.minutes

        conflicting_events = Event.available_slots(@professional_id, start_time, end_time)

        if conflicting_events.empty?
          return {
            start_time: start_time,
            end_time: end_time,
            date: date,
            hour: hour
          }
        end
      end

      date += 1.day
      attempts += 1
    end

    nil # Não encontrou horário disponível
  end

  def get_conflicts_with_event(event_id, start_time, end_time)
    Event.available_slots(@professional_id, start_time, end_time)
         .where.not(id: event_id)
  end

  def can_reschedule_event(event_id, new_start_time, new_end_time)
    conflicts = get_conflicts_with_event(event_id, new_start_time, new_end_time)
    conflicts.empty?
  end

  private

  def calculate_available_slots(start_time, end_time)
    total_minutes = ((end_time - start_time) / 1.minute).to_i
    available_minutes = total_minutes

    conflicting_events = Event.active_in_time_range(@professional_id, start_time, end_time)

    conflicting_events.each do |event|
      overlap_start = [start_time, event.start_time].max
      overlap_end = [end_time, event.end_time].min
      overlap_minutes = ((overlap_end - overlap_start) / 1.minute).to_i

      available_minutes -= overlap_minutes if overlap_minutes.positive?
    end

    {
      total_minutes: total_minutes,
      available_minutes: [available_minutes, 0].max,
      occupied_minutes: total_minutes - [available_minutes, 0].max,
      utilization_percentage: (total_minutes.positive? ? ((total_minutes - available_minutes) / total_minutes.to_f * 100).round(2) : 0)
    }
  end
end
