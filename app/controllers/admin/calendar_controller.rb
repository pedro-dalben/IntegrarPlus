# frozen_string_literal: true

module Admin
  class CalendarController < Admin::BaseController
    def index
      @current_date = params[:date].present? ? Date.parse(params[:date]) : Date.current
      @view_type = params[:view] || 'month'
      @professional = User.find(params[:professional_id]) if params[:professional_id].present?
      @agenda = Agenda.find(params[:agenda_id]) if params[:agenda_id].present?

      @events = load_events

      respond_to do |format|
        format.html do
          render partial: 'admin/calendar/calendar', locals: {
            events: @events,
            professional: @professional,
            view_type: @view_type,
            current_date: @current_date,
            agenda: @agenda
          }
        end
      end
    end

    private

    def load_events
      events = Event.includes(:professional, :created_by, :medical_appointment)

      events = events.where(professional: @professional) if @professional.present?

      if @agenda.present?
        events = events.joins(:medical_appointment)
                       .where(medical_appointments: { agenda: @agenda })
      end

      case @view_type
      when 'month'
        events.where(start_time: @current_date.all_month)
      when 'week'
        events.where(start_time: @current_date.all_week)
      when 'day'
        events.where(start_time: @current_date.all_day)
      else
        events.where(start_time: @current_date.all_month)
      end.order(:start_time)
    end
  end
end
