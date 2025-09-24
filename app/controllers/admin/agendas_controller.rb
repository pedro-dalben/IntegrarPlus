class Admin::AgendasController < Admin::BaseController
  before_action :set_agenda, only: %i[show edit update destroy archive activate duplicate]
  before_action :authorize_agenda, only: %i[show edit update destroy archive activate duplicate]

  def index
    @agendas = policy_scope(Agenda)
               .includes(:unit, :created_by, :professionals)
               .order(created_at: :desc)

    apply_filters
    apply_search

    # @agendas = @agendas.page(params[:page]).per(20) # Paginação desabilitada temporariamente
  end

  def show
    # Buscar eventos através dos profissionais da agenda
    @recent_events = Event.joins(:professional)
                          .where(professional: @agenda.professionals)
                          .includes(:professional, :medical_appointment)
                          .order(start_time: :desc)
                          .limit(10)

    # Buscar appointments que NÃO têm evento associado (para casos especiais)
    @recent_appointments = MedicalAppointment.joins(:professional)
                                             .where(professional: @agenda.professionals)
                                             .where(event: nil)
                                             .includes(:professional, :patient)
                                             .order(scheduled_at: :desc)
                                             .limit(10)

    # Para o calendário, usar apenas os eventos (que já incluem os appointments associados)
    @all_events = @recent_events
  end

  def new
    @agenda = Agenda.new
    @agenda.working_hours = default_working_hours
    authorize @agenda
  end

  def edit
    @current_step = params[:step] || 'metadata'
  end

  def create
    @agenda = Agenda.new(agenda_params)
    @agenda.created_by = current_user
    @agenda.updated_by = current_user
    authorize @agenda

    # Processar professional_ids se fornecidos
    @agenda.professional_ids = params[:professional_ids] if params[:professional_ids].present?

    if @agenda.save
      redirect_to admin_agenda_path(@agenda), notice: 'Agenda criada com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @agenda.update(agenda_params.merge(updated_by: current_user))
      if params[:commit] == 'Salvar e Continuar'
        next_step = determine_next_step
        redirect_to edit_admin_agenda_path(@agenda, step: next_step), notice: 'Alterações salvas.'
      elsif params[:commit] == 'Ativar Agenda'
        @agenda.update!(status: :active)
        redirect_to admin_agenda_path(@agenda), notice: 'Agenda ativada com sucesso.'
      else
        redirect_to admin_agenda_path(@agenda), notice: 'Agenda atualizada com sucesso.'
      end
    else
      @current_step = params[:step] || 'metadata'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @agenda.can_be_deleted?
      @agenda.destroy!
      redirect_to admin_agendas_path, notice: 'Agenda excluída com sucesso.'
    else
      redirect_to admin_agenda_path(@agenda), alert: 'Não é possível excluir uma agenda que possui eventos.'
    end
  end

  def archive
    @agenda.update!(status: :archived, updated_by: current_user)
    redirect_to admin_agendas_path, notice: 'Agenda arquivada com sucesso.'
  end

  def activate
    @agenda.update!(status: :active, updated_by: current_user)
    redirect_to admin_agendas_path, notice: 'Agenda ativada com sucesso.'
  end

  def duplicate
    new_agenda = @agenda.duplicate!
    if new_agenda.persisted?
      redirect_to edit_admin_agenda_path(new_agenda), notice: 'Agenda duplicada com sucesso.'
    else
      redirect_to admin_agenda_path(@agenda), alert: 'Erro ao duplicar agenda.'
    end
  end

  def preview_slots
    # Se for uma agenda existente, usar ela
    if params[:id].present?
      @agenda = Agenda.find(params[:id])
      authorize @agenda
    else
      # Se for uma nova agenda, criar um objeto temporário com os dados fornecidos
      @agenda = Agenda.new(working_hours: JSON.parse(params[:working_hours] || '{}'))
    end

    @preview_data = generate_slots_preview(@agenda)

    respond_to do |format|
      format.turbo_stream
    end
  end

  def search_professionals
    @professionals = User.professionals
                         .includes(professional: :specialities)
                         .joins(:professional)
                         .where(professionals: { active: true })

    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @professionals = @professionals.where(
        'users.email ILIKE ? OR professionals.full_name ILIKE ?',
        search_term, search_term
      )
    end

    @professionals = @professionals.limit(20)

    respond_to do |format|
      format.json do
        render json: {
          professionals: @professionals.map do |professional|
            {
              id: professional.id,
              name: professional.name,
              specialties: professional.professional.specialities.pluck(:name)
            }
          end
        }
      end
    end
  end

  def configure_schedule
    professional_id = params[:professional_id]
    agenda_id = params[:agenda_id]

    professional = User.find(professional_id) if professional_id.present?
    agenda = Agenda.find(agenda_id) if agenda_id.present?

    return render json: { success: false, error: 'Profissional ou agenda não encontrado' } unless professional && agenda

    configuration_service = AvailabilityConfigurationService.new(professional, agenda)
    result = configuration_service.set_custom_schedule(schedule_params)

    respond_to do |format|
      format.json { render json: result }
    end
  end

  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def authorize_agenda
    authorize @agenda
  end

  def agenda_params
    params.require(:agenda).permit(
      :name, :service_type, :default_visibility, :unit_id, :color_theme, :notes,
      :slot_duration_minutes, :buffer_minutes, :status,
      working_hours: {},
      professional_ids: []
    )
  end

  def schedule_params
    schedule_data = []

    (0..6).each do |day|
      day_params = params.dig(:schedule, day.to_s)
      next unless day_params

      day_data = {
        day_of_week: day,
        enabled: day_params[:enabled] == 'true',
        periods: []
      }

      if day_params[:periods].present?
        day_params[:periods].each do |period_key, period_data|
          day_data[:periods] << {
            start_time: period_data[:start_time],
            end_time: period_data[:end_time]
          }
        end
      end

      schedule_data << day_data
    end

    schedule_data
  end

  def apply_filters
    @agendas = @agendas.by_service_type(params[:service_type]) if params[:service_type].present?

    @agendas = @agendas.where(status: params[:status]) if params[:status].present?

    @agendas = @agendas.by_unit(params[:unit_id]) if params[:unit_id].present?

    return unless params[:professional_id].present?

    @agendas = @agendas.with_professional(params[:professional_id])
  end

  def apply_search
    return unless params[:search].present?

    search_term = "%#{params[:search]}%"
    @agendas = @agendas.where(
      'agendas.name ILIKE ? OR agendas.notes ILIKE ?',
      search_term, search_term
    )
  end

  def default_working_hours
    {
      'slot_duration' => 50,
      'buffer' => 10,
      'weekdays' => [],
      'exceptions' => []
    }
  end

  def determine_next_step
    case params[:step]
    when 'metadata'
      'professionals'
    when 'professionals'
      'working_hours'
    when 'working_hours'
      'review'
    else
      'review'
    end
  end

  def generate_slots_preview(agenda)
    return {} unless agenda.working_hours.present?

    preview_data = {}
    start_date = Date.current
    end_date = start_date + 14.days

    # Se for uma agenda temporária (nova), usar profissionais padrão
    professionals = if agenda.persisted?
                      agenda.professionals.active
                    else
                      # Para preview de nova agenda, usar todos os profissionais ativos
                      User.professionals.includes(professional: :specialities)
                          .joins(:professional)
                          .where(professionals: { active: true })
                    end

    professionals.each do |professional|
      preview_data[professional.id] = {
        name: professional.name,
        slots: []
      }

      (start_date..end_date).each do |date|
        day_slots = generate_day_slots(agenda, professional, date)
        preview_data[professional.id][:slots].concat(day_slots)
      end
    end

    preview_data
  end

  def generate_day_slots(agenda, professional, date)
    return [] unless agenda.working_hours['weekdays'].present?

    weekday = date.wday
    day_config = agenda.working_hours['weekdays'].find { |d| d['wday'] == weekday }
    return [] unless day_config&.dig('periods').present?

    slots = []
    day_config['periods'].each do |period|
      start_time = Time.parse("#{date} #{period['start']}")
      end_time = Time.parse("#{date} #{period['end']}")

      current_time = start_time
      while current_time + agenda.slot_duration_minutes.minutes <= end_time
        slot_end = current_time + agenda.slot_duration_minutes.minutes

        slots << {
          start_time: current_time,
          end_time: slot_end,
          available: true
        }

        current_time = slot_end + agenda.buffer_minutes.minutes
      end
    end

    slots
  end
end
