# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    before_action :authenticate_user!

    def index
      # Dados da agenda (sem cache para dados sempre atualizados)
      @agenda_data = agenda_data
    end

    private

    def agenda_data
      {
        # Eventos da semana atual
        this_week_events: Event.includes(:professional, :created_by)
                               .where(start_time: Date.current.all_week)
                               .order(:start_time),

        # Eventos de hoje
        today_events: Event.includes(:professional, :created_by)
                           .where(start_time: Date.current.all_day)
                           .order(:start_time),

        # Próximos eventos (próximas 24h)
        next_24h_events: Event.includes(:professional, :created_by)
                              .where('start_time > ? AND start_time < ?', Time.current, 24.hours.from_now)
                              .order(:start_time),

        # Estatísticas por profissional
        events_by_professional: Professional.joins(:events)
                                            .group('professionals.id', 'professionals.full_name')
                                            .count
                                            .sort_by { |_, count| -count }
                                            .first(10),

        # Eventos por tipo hoje
        today_events_by_type: Event.where(start_time: Date.current.all_day)
                                   .group(:event_type)
                                   .count,

        # Eventos públicos vs privados
        visibility_summary: Event.group(:visibility_level).count,

        # Horários mais ocupados (últimos 7 dias)
        busy_hours: calculate_busy_hours,

        # Métricas resumidas da agenda
        metrics: {
          total_events: Event.count,
          events_this_month: Event.where(created_at: Time.current.all_month).count,
          events_today: Event.where(start_time: Date.current.all_day).count,
          upcoming_events: Event.where('start_time > ?', Time.current).count,
          total_professionals_with_events: Professional.joins(:events).distinct.count
        }
      }
    end

    def calculate_busy_hours
      last_week_events = Event.where(
        start_time: 7.days.ago.beginning_of_day..Date.current.end_of_day
      )

      hour_counts = {}
      (8..18).each do |hour|
        hour_counts[hour] = last_week_events.where(
          'EXTRACT(hour FROM start_time) = ?', hour
        ).count
      end

      hour_counts
    end
  end
end
