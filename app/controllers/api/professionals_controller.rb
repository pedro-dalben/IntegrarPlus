class Api::ProfessionalsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_professional_access

  def index
    @professionals = User.professionals
                         .includes(professional: :specialities)
                         .joins(:professional)

    apply_filters
    apply_search

    @professionals = @professionals.limit(50)

    respond_to do |format|
      format.json do
        render json: {
          professionals: @professionals.map do |professional|
            {
              id: professional.id,
              name: professional.name,
              email: professional.email,
              specialties: professional.professional.specialities.pluck(:name),
              avatar_url: professional.avatar.attached? ? url_for(professional.avatar) : nil,
              is_active: professional.professional.active?
            }
          end,
          total_count: @professionals.count
        }
      end
    end
  end

  def show
    @professional = User.professionals.find(params[:id])

    respond_to do |format|
      format.json do
        render json: {
          professional: {
            id: @professional.id,
            name: @professional.name,
            email: @professional.email,
            specialties: @professional.professional.specialities.pluck(:name),
            avatar_url: @professional.avatar.attached? ? url_for(@professional.avatar) : nil,
            is_active: @professional.professional.active?,
            availability: get_professional_availability(@professional)
          }
        }
      end
    end
  end

  def search
    query = params[:q].to_s.strip

    if query.length < 2
      render json: { professionals: [] }
      return
    end

    @professionals = User.professionals
                         .includes(professional: :specialities)
                         .joins(:professional)
                         .where(professionals: { active: true })

    # Busca por nome ou email
    search_term = "%#{query}%"
    @professionals = @professionals.where(
      'professionals.full_name ILIKE ? OR users.email ILIKE ?',
      search_term, search_term
    )

    @professionals = @professionals.limit(20)

    respond_to do |format|
      format.json do
        render json: {
          professionals: @professionals.map do |user|
            {
              id: user.professional.id,
              full_name: user.professional.full_name,
              email: user.email,
              avatar_url: user.avatar.attached? ? url_for(user.avatar) : nil,
              specialties: user.professional.specialities.pluck(:name),
              is_active: user.professional.active?
            }
          end
        }
      end
    end
  end

  def availability
    @professional = User.professionals.find(params[:id])
    @agenda = Agenda.find(params[:agenda_id]) if params[:agenda_id].present?

    date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    duration_minutes = params[:duration_minutes]&.to_i || 50

    scheduling_service = AppointmentSchedulingService.new(@professional, @agenda)
    available_slots = scheduling_service.get_available_slots(date, duration_minutes)

    respond_to do |format|
      format.json do
        render json: {
          professional: {
            id: @professional.id,
            name: @professional.name
          },
          date: date,
          available_slots: available_slots.map do |slot|
            {
              start_time: slot[:start_time].strftime('%H:%M'),
              end_time: slot[:end_time].strftime('%H:%M'),
              available: slot[:available],
              conflicts: slot[:conflicts].map do |conflict|
                {
                  type: conflict[:type],
                  description: get_conflict_description(conflict[:object])
                }
              end
            }
          end
        }
      end
    end
  end

  private

  def authorize_professional_access
    authorize :professional, :access?
  end

  def apply_filters
    @professionals = @professionals.where(professionals: { active: true }) if params[:active_only] == 'true'

    if params[:specialty_id].present?
      @professionals = @professionals.joins(professional: :specialities)
                                     .where(specialities: { id: params[:specialty_id] })
    end

    return unless params[:unit_id].present?

    @professionals = @professionals.joins(professional: :units)
                                   .where(units: { id: params[:unit_id] })
  end

  def apply_search
    return unless params[:search].present?

    search_term = "%#{params[:search]}%"
    @professionals = @professionals.where(
      'users.email ILIKE ? OR professionals.full_name ILIKE ?',
      search_term, search_term
    )
  end

  def get_professional_availability(professional)
    return {} unless params[:agenda_id].present?

    agenda = Agenda.find(params[:agenda_id])
    configuration_service = AvailabilityConfigurationService.new(professional, agenda)

    {
      weekly_schedule: configuration_service.get_weekly_schedule,
      next_available_date: get_next_available_date(professional, agenda)
    }
  end

  def get_next_available_date(professional, agenda)
    (Date.current..Date.current + 30.days).find do |date|
      availability = AvailabilityConfigurationService.new(professional, agenda)
                                                     .get_availability_for_date(date)
      availability[:is_available]
    end
  end

  def get_conflict_description(conflict_object)
    case conflict_object
    when Event
      "Evento: #{conflict_object.title}"
    when MedicalAppointment
      "Agendamento: #{conflict_object.appointment_type.humanize}"
    when AvailabilityException
      "Exceção: #{conflict_object.description}"
    else
      'Conflito desconhecido'
    end
  end
end
