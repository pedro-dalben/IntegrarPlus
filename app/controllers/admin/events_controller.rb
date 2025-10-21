# frozen_string_literal: true

module Admin
  class EventsController < Admin::BaseController
    before_action :set_event, only: %i[show edit update destroy]
    before_action :ensure_owner_or_permission, only: %i[edit update destroy]

    def index
      @pagy, @events = pagy(
        current_user.professional.events
                    .includes(:created_by)
                    .order(:start_time),
        items: 20
      )
    end

    def show; end

    def new
      @event = current_user.professional.events.build
      @event.start_time = Time.current.beginning_of_hour + 1.hour
      @event.end_time = @event.start_time + 1.hour
    end

    def edit; end

    def create
      @event = current_user.professional.events.build(event_params)
      @event.created_by = current_user.professional

      if @event.save
        respond_to do |format|
          format.html { redirect_to admin_events_path, notice: 'Evento criado com sucesso.' }
          format.json { render json: @event, status: :created }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              'events_list',
              partial: 'admin/events/events_list',
              locals: { events: current_user.professional.events.order(:start_time) }
            )
          end
        end
      else
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              'events_list',
              partial: 'admin/events/form',
              locals: { event: @event }
            )
          end
        end
      end
    end

    def update
      if @event.update(event_params)
        respond_to do |format|
          format.html { redirect_to admin_events_path, notice: 'Evento atualizado com sucesso.' }
          format.json { render json: @event }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              'events_list',
              partial: 'admin/events/events_list',
              locals: { events: current_user.professional.events.order(:start_time) }
            )
          end
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              'events_list',
              partial: 'admin/events/form',
              locals: { event: @event }
            )
          end
        end
      end
    end

    def destroy
      @event.destroy
      respond_to do |format|
        format.html { redirect_to admin_events_path, notice: 'Evento removido com sucesso.' }
        format.json { head :no_content }
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove(@event)
        end
      end
    end

    def test_calendar
      # Página de teste para o calendário
    end

    def calendar_data
      start_date = params[:start]&.to_date || Date.current.beginning_of_month
      end_date = params[:end]&.to_date || Date.current.end_of_month
      @events = current_user.professional.events
                            .where(start_time: start_date.beginning_of_day..end_date.end_of_day)
                            .includes(:created_by)

      calendar_events = @events.map do |event|
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
            description: event.description
          }
        }
      end
      render json: calendar_events
    end

    private

    def set_event
      @event = current_user.professional.events.find(params[:id])
    end

    def ensure_owner_or_permission
      return if @event.created_by == current_user.professional || current_user.professional.permit?(:manage_events)

      redirect_to admin_events_path, alert: 'Você não tem permissão para realizar esta ação.'
    end

    def event_params
      params.expect(
        event: %i[title description start_time end_time
                  event_type visibility_level source_context status]
      )
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
end
