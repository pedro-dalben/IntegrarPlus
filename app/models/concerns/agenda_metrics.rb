# frozen_string_literal: true

module AgendaMetrics
  extend ActiveSupport::Concern

  class_methods do
    def calculate_occupancy_rate(agenda, date_range = 30.days.ago..Date.current)
      total_slots = agenda.calculate_total_slots(date_range)
      return 0 if total_slots.zero?

      occupied_slots = Event.where(
        agenda: agenda,
        start_time: date_range
      ).count

      (occupied_slots.to_f / total_slots * 100).round(2)
    end

    def calculate_average_occupancy_rate
      active_agendas = Agenda.active
      return 0 if active_agendas.empty?

      total_rate = active_agendas.sum { |agenda| calculate_occupancy_rate(agenda) }
      (total_rate / active_agendas.count).round(2)
    end

    def calculate_total_available_slots(days_ahead = 7)
      Agenda.active.sum { |agenda| agenda.available_slots_count(days_ahead) }
    end

    def calculate_agendas_growth
      current_month = Agenda.where(created_at: Date.current.beginning_of_month..).count
      last_month = Agenda.where(created_at: 1.month.ago.beginning_of_month...1.month.ago.end_of_month).count

      return 0 if last_month.zero?

      ((current_month - last_month).to_f / last_month * 100).round(1)
    end

    def calculate_events_growth
      current_month = Event.where(created_at: Date.current.beginning_of_month..).count
      last_month = Event.where(created_at: 1.month.ago.beginning_of_month...1.month.ago.end_of_month).count

      return 0 if last_month.zero?

      ((current_month - last_month).to_f / last_month * 100).round(1)
    end

    def calculate_monthly_occupancy(date_range)
      total_events = Event.where(start_time: date_range).count
      total_slots = Agenda.active.sum { |agenda| agenda.calculate_total_slots(date_range) }

      return 0 if total_slots.zero?

      (total_events.to_f / total_slots * 100).round(2)
    end
  end
end
