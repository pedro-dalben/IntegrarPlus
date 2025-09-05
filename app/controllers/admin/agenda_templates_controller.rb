class Admin::AgendaTemplatesController < Admin::BaseController
  before_action :set_template, only: %i[show edit update destroy duplicate]
  before_action :authorize_template, only: %i[show edit update destroy duplicate]

  def index
    @templates = policy_scope(AgendaTemplate)
                 .includes(:created_by)
                 .order(created_at: :desc)

    apply_filters
    apply_search
  end

  def show
    @preview_data = @template.preview_data
  end

  def new
    @template = AgendaTemplate.new
    @template.template_data = default_template_data
    authorize @template
  end

  def create
    @template = AgendaTemplate.new(template_params)
    @template.created_by = current_user
    authorize @template

    if @template.save
      redirect_to admin_agenda_template_path(@template), notice: 'Template criado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @template.update(template_params)
      redirect_to admin_agenda_template_path(@template), notice: 'Template atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @template.usage_count.zero?
      @template.destroy!
      redirect_to admin_agenda_templates_path, notice: 'Template excluído com sucesso.'
    else
      redirect_to admin_agenda_template_path(@template), alert: 'Não é possível excluir um template que já foi utilizado.'
    end
  end

  def duplicate
    new_template = @template.duplicate_for_user(current_user)
    if new_template.persisted?
      redirect_to edit_admin_agenda_template_path(new_template), notice: 'Template duplicado com sucesso.'
    else
      redirect_to admin_agenda_template_path(@template), alert: 'Erro ao duplicar template.'
    end
  end

  def create_from_agenda
    @agenda = Agenda.find(params[:agenda_id])
    authorize @agenda

    @template = AgendaTemplate.create_from_agenda(@agenda, params[:template_name])

    if @template.persisted?
      redirect_to admin_agenda_template_path(@template), notice: 'Template criado a partir da agenda com sucesso.'
    else
      redirect_to admin_agenda_path(@agenda), alert: 'Erro ao criar template a partir da agenda.'
    end
  end

  def create_agenda_from_template
    @template = AgendaTemplate.find(params[:id])
    authorize @template

    @agenda = @template.create_agenda_from_template(current_user, agenda_params)

    if @agenda&.persisted?
      redirect_to edit_admin_agenda_path(@agenda), notice: 'Agenda criada a partir do template com sucesso.'
    else
      redirect_to admin_agenda_template_path(@template), alert: 'Erro ao criar agenda a partir do template.'
    end
  end

  private

  def set_template
    @template = AgendaTemplate.find(params[:id])
  end

  def authorize_template
    authorize @template
  end

  def template_params
    params.require(:agenda_template).permit(
      :name, :description, :category, :visibility,
      template_data: {}
    )
  end

  def agenda_params
    params.require(:agenda).permit(
      :name, :unit_id, :notes,
      professional_ids: []
    )
  end

  def apply_filters
    @templates = @templates.by_category(params[:category]) if params[:category].present?
    @templates = @templates.where(visibility: params[:visibility]) if params[:visibility].present?
  end

  def apply_search
    return unless params[:search].present?

    search_term = "%#{params[:search]}%"
    @templates = @templates.where(
      'agenda_templates.name ILIKE ? OR agenda_templates.description ILIKE ?',
      search_term, search_term
    )
  end

  def default_template_data
    {
      'service_type' => 'consulta',
      'default_visibility' => 'restricted',
      'slot_duration_minutes' => 50,
      'buffer_minutes' => 10,
      'color_theme' => '#3B82F6',
      'working_hours' => AgendaTemplate.default_working_hours
    }
  end
end
