# frozen_string_literal: true

module Admin
  class AgendaDashboardController < Admin::BaseController
    include AgendaMetrics

    before_action :authorize_dashboard_access

    def index
      @metrics = calculate_dashboard_metrics
      @recent_activities = fetch_recent_activities
      @alerts = fetch_system_alerts
      @trends = calculate_trends
    end

    def occupancy_chart
      @data = calculate_occupancy_chart_data(params[:period] || '30_days')

      respond_to do |format|
        format.json { render json: @data }
      end
    end

    def utilization_chart
      @data = calculate_utilization_chart_data(params[:professional_ids])

      respond_to do |format|
        format.json { render json: @data }
      end
    end

    def trends_chart
      @data = calculate_trends_chart_data(params[:period] || '6_months')

      respond_to do |format|
        format.json { render json: @data }
      end
    end

    private

    def authorize_dashboard_access
      authorize :agenda_dashboard, :index?
    end

    def calculate_dashboard_metrics
      {
        active_agendas_count: Agenda.active.count,
        active_professionals_count: Professional.joins(:agenda_professionals).distinct.count,
        available_slots_count: calculate_total_available_slots,
        occupancy_rate: calculate_average_occupancy_rate,
        agendas_with_conflicts: Agenda.active.count(&:has_conflicts?),
        total_events_today: Event.where(start_time: Date.current.all_day).count,
        upcoming_events: Event.where('start_time > ? AND start_time <= ?', Time.current, 7.days.from_now).count
      }
    end

    def calculate_total_available_slots
      AgendaMetrics.calculate_total_available_slots(7)
    end

    def calculate_average_occupancy_rate
      AgendaMetrics.calculate_average_occupancy_rate
    end

    def fetch_recent_activities
      activities = []

      activities += Agenda.where('created_at > ?', 7.days.ago)
                          .includes(:created_by, :unit)
                          .order(created_at: :desc)
                          .limit(5)
                          .map { |agenda| { type: 'agenda_created', object: agenda, date: agenda.created_at } }

      activities += Event.where('created_at > ?', 7.days.ago)
                         .includes(:professional)
                         .order(created_at: :desc)
                         .limit(5)
                         .map { |event| { type: 'event_created', object: event, date: event.created_at } }

      activities.sort_by { |activity| activity[:date] }.last(10).reverse
    end

    def fetch_system_alerts
      alerts = []

      Agenda.active.each do |agenda|
        if agenda.has_conflicts?
          alerts << {
            type: 'conflict',
            severity: 'high',
            message: "Agenda '#{agenda.name}' possui conflitos de horário",
            agenda: agenda
          }
        end

        next unless agenda.occupancy_rate < 30

        alerts << {
          type: 'low_occupancy',
          severity: 'medium',
          message: "Agenda '#{agenda.name}' com baixa ocupação (#{agenda.occupancy_rate}%)",
          agenda: agenda
        }
      end

      alerts
    end

    def calculate_trends
      {
        agendas_growth: calculate_agendas_growth,
        events_growth: calculate_events_growth,
        occupancy_trend: calculate_occupancy_trend
      }
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

    def calculate_occupancy_trend
      current_month_occupancy = calculate_monthly_occupancy(Date.current.all_month)
      last_month_occupancy = calculate_monthly_occupancy(1.month.ago.all_month)

      return 0 if last_month_occupancy.zero?

      ((current_month_occupancy - last_month_occupancy).to_f / last_month_occupancy * 100).round(1)
    end

    def calculate_monthly_occupancy(date_range)
      total_events = Event.where(start_time: date_range).count
      total_slots = Agenda.active.sum { |agenda| agenda.calculate_total_slots(date_range) }

      return 0 if total_slots.zero?

      (total_events.to_f / total_slots * 100).round(2)
    end

    def calculate_occupancy_chart_data(period)
      case period
      when '7_days'
        calculate_daily_occupancy(7.days.ago..Date.current)
      when '30_days'
        calculate_daily_occupancy(30.days.ago..Date.current)
      when '3_months'
        calculate_weekly_occupancy(3.months.ago..Date.current)
      else
        calculate_daily_occupancy(30.days.ago..Date.current)
      end
    end

    def calculate_daily_occupancy(date_range)
      data = []

      date_range.each do |date|
        day_events = Event.where(start_time: date.all_day).count
        day_slots = Agenda.active.sum { |agenda| agenda.calculate_total_slots(date..date) }
        occupancy = day_slots.zero? ? 0 : (day_events.to_f / day_slots * 100).round(2)

        data << {
          date: date.strftime('%d/%m'),
          occupancy: occupancy,
          events: day_events,
          slots: day_slots
        }
      end

      data
    end

    def calculate_weekly_occupancy(date_range)
      data = []

      date_range.step(7.days) do |week_start|
        week_end = [week_start + 6.days, Date.current].min
        week_events = Event.where(start_time: week_start..week_end).count
        week_slots = Agenda.active.sum { |agenda| agenda.calculate_total_slots(week_start..week_end) }
        occupancy = week_slots.zero? ? 0 : (week_events.to_f / week_slots * 100).round(2)

        data << {
          week: week_start.strftime('%d/%m'),
          occupancy: occupancy,
          events: week_events,
          slots: week_slots
        }
      end

      data
    end

    def calculate_utilization_chart_data(professional_ids = nil)
      professionals = professional_ids ? Professional.where(id: professional_ids) : Professional.joins(:agenda_professionals).distinct

      professionals.map do |professional|
        professional_events = Event.where(professional: professional, start_time: 30.days.ago..Date.current).count
        professional_slots = professional.agendas.active.sum do |agenda|
          agenda.calculate_total_slots(30.days.ago..Date.current)
        end
        utilization = professional_slots.zero? ? 0 : (professional_events.to_f / professional_slots * 100).round(2)

        {
          name: professional.full_name,
          utilization: utilization,
          events: professional_events,
          slots: professional_slots
        }
      end
    end

    def calculate_trends_chart_data(period)
      case period
      when '3_months'
        calculate_monthly_trends(3.months.ago..Date.current)
      when '6_months'
        calculate_monthly_trends(6.months.ago..Date.current)
      when '1_year'
        calculate_monthly_trends(1.year.ago..Date.current)
      else
        calculate_monthly_trends(6.months.ago..Date.current)
      end
    end

    def calculate_monthly_trends(date_range)
      data = []

      date_range.step(1.month) do |month_start|
        month_end = [month_start.end_of_month, Date.current].min
        month_events = Event.where(start_time: month_start..month_end).count
        month_slots = Agenda.active.sum { |agenda| agenda.calculate_total_slots(month_start..month_end) }
        occupancy = month_slots.zero? ? 0 : (month_events.to_f / month_slots * 100).round(2)

        data << {
          month: month_start.strftime('%m/%Y'),
          occupancy: occupancy,
          events: month_events,
          slots: month_slots
        }
      end

      data
    end
  end
end
