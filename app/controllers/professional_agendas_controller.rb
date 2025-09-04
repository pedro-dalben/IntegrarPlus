# frozen_string_literal: true

class ProfessionalAgendasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_professional, only: %i[show availability events_data]

  def index
    @professionals = Professional.active.ordered.includes(:user)
    respond_to do |format|
      format.html
      format.json { render json: @professionals.map { |p| { id: p.id, name: p.full_name, email: p.email } } }
    end
  end

  def show
    @date = params[:date]&.to_date || Date.current
    @view_type = params[:view] || 'week'
    respond_to do |format|
      format.html
      format.json { render json: { professional: @professional, date: @date, view_type: @view_type } }
    end
  end

  def availability
    start_time = params[:start_time]&.to_datetime
    end_time = params[:end_time]&.to_datetime

    unless start_time && end_time
      render json: { error: 'Parâmetros start_time e end_time são obrigatórios' }, status: :bad_request
      return
    end

    availability_data = Event.availability_for_professional(
      @professional.id,
      start_time,
      end_time
    )
    render json: availability_data
  end

  def events_data
    start_date = params[:start]&.to_date || Date.current.beginning_of_month
    end_date = params[:end]&.to_date || Date.current.end_of_month

    viewing_professional = current_user.professional
    events = Event.visible_for_professional(viewing_professional, @professional.id)
                  .where(start_time: start_date.beginning_of_day..end_date.end_of_day)
                  .includes(:created_by)
                  .order(:start_time)

    calendar_events = events.map do |event|
      if event.visible_for_professional?(viewing_professional)
        {
          id: event.id,
          title: event.title,
          start: event.start_time.iso8601,
          end: event.end_time.iso8601,
          backgroundColor: event_color(event.event_type),
          borderColor: event_color(event.event_type),
          textColor: '#ffffff',
          extendedProps: {
            event_type: event.event_type,
            visibility_level: event.visibility_level,
            description: event.description,
            created_by: event.created_by.full_name
          }
        }
      else
        {
          id: event.id,
          title: 'Ocupado',
          start: event.start_time.iso8601,
          end: event.end_time.iso8601,
          backgroundColor: '#6b7280',
          borderColor: '#6b7280',
          textColor: '#ffffff',
          extendedProps: {
            event_type: 'ocupado',
            visibility_level: 'masked',
            description: nil,
            created_by: nil
          }
        }
      end
    end
    render json: calendar_events
  end

  private

  def set_professional
    @professional = Professional.find(params[:id])
  end

  def event_color(event_type)
    case event_type
    when 'personal' then '#3b82f6'
    when 'consulta' then '#10b981'
    when 'atendimento' then '#f59e0b'
    when 'reuniao' then '#8b5cf6'
    when 'outro' then '#6b7280'
    else '#3b82f6'
    end
  end
end
