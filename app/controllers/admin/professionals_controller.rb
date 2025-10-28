# frozen_string_literal: true

module Admin
  class ProfessionalsController < BaseController
    before_action :set_professional, only: %i[show edit update destroy create_user toggle_active]

    def index
      @professionals = params[:query].present? ? perform_search : perform_local_search
      @pagy, @professionals = pagy(@professionals, items: 10)

      respond_to do |format|
        format.html do
          render partial: 'search_results', layout: false if request.xhr?
        end
        format.json { render json: format_professionals_for_json }
      end
    end

    def show; end

    def new
      @professional = Professional.new
      load_form_data
    end

    def edit
      load_form_data
    end

    def create
      @professional = Professional.new(professional_params)

      Rails.logger.info "Parâmetros recebidos: #{params[:professional].inspect}"
      Rails.logger.info "Parâmetros processados: #{professional_params.inspect}"

      if @professional.save
        handle_successful_creation
      else
        Rails.logger.error "Erros de validação: #{@professional.errors.full_messages}"
        handle_failed_creation
      end
    end

    def update
      Rails.logger.info "Parâmetros de atualização: #{params[:professional].inspect}"
      Rails.logger.info "Parâmetros processados: #{professional_params.inspect}"

      if @professional.update(professional_params)
        redirect_to admin_professional_path(@professional),
                    notice: t('admin.professionals.messages.updated')
      else
        Rails.logger.error "Erros de validação na atualização: #{@professional.errors.full_messages}"
        load_form_data
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @professional.documents.exists?
        redirect_to admin_professional_path(@professional),
                    alert: t('admin.professionals.messages.cannot_delete_with_documents')
        return
      end

      @professional.destroy
      redirect_to admin_professionals_path,
                  notice: t('admin.professionals.messages.deleted')
    end

    def create_user
      if @professional.user.present?
        redirect_to admin_professional_path(@professional),
                    alert: t('admin.professionals.messages.user_already_exists')
        return
      end

      user = @professional.create_user_for_authentication!
      if user
        redirect_to admin_professional_path(@professional),
                    notice: t('admin.professionals.messages.user_created')
      else
        redirect_to admin_professional_path(@professional),
                    alert: t('admin.professionals.messages.user_creation_failed')
      end
    end

    def toggle_active
      if @professional.active? && has_future_appointments?
        redirect_to admin_professional_path(@professional),
                    alert: 'Não é possível desativar o profissional pois existem agendamentos futuros.'
        return
      end

      if @professional.update(active: !@professional.active)
        message_key = @professional.active? ? :activated : :deactivated
        redirect_to admin_professional_path(@professional),
                    notice: t("admin.professionals.messages.#{message_key}")
      else
        redirect_to admin_professional_path(@professional),
                    alert: 'Erro ao alterar status do profissional.'
      end
    end

    private

    def perform_search
      search_service = AdvancedSearchService.new(Professional)
      filters = build_search_filters
      options = build_search_options

      search_service.search(params[:query], filters, options)
    rescue StandardError => e
      Rails.logger.error "Erro na busca avançada: #{e.message}"
      perform_local_search
    end

    def perform_local_search
      Professional.includes(user: :invites)
                  .order(created_at: :desc)
    end

    def build_search_filters
      {}.tap do |filters|
        filters[:active] = params[:active] == 'true' if params[:active].present?
        filters[:contract_type_id] = params[:contract_type_id] if params[:contract_type_id].present?
      end
    end

    def build_search_options
      {
        limit: 1000,
        sort: [build_sort_param]
      }
    end

    def build_sort_param
      order_by = params[:order_by] || 'created_at'
      direction = params[:direction] || 'desc'

      allowed_orders = %w[full_name email created_at updated_at]
      order_by = 'created_at' unless allowed_orders.include?(order_by)

      "#{order_by}:#{direction}"
    end

    def format_professionals_for_json
      {
        results: @professionals.map { |p| format_professional_for_json(p) },
        count: @pagy.count
      }
    end

    def format_professional_for_json(professional)
      {
        id: professional.id,
        full_name: professional.full_name,
        email: professional.email,
        active: professional.active?,
        has_user: professional.user.present?
      }
    end

    def handle_successful_creation
      redirect_to admin_professional_path(@professional),
                  notice: t('admin.professionals.messages.created')
    end

    def handle_failed_creation
      load_form_data
      render :new, status: :unprocessable_entity
    end

    def set_professional
      @professional = Professional.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_professionals_path, alert: t('admin.professionals.messages.not_found')
    end

    def professional_params
      Rails.logger.info "Parâmetros brutos: #{params.inspect}"

      permitted_params = params.expect(
        professional: [:full_name, :birth_date, :cpf, :phone, :email, :active,
                       :contract_type_id, :hired_on, :workload_hhmm, :workload_minutes,
                       :council_code, :company_name, :cnpj,
                       { primary_address_attributes: %i[
                           id zip_code street number complement
                           neighborhood city state latitude longitude _destroy
                         ],
                         secondary_address_attributes: %i[
                           id zip_code street number complement
                           neighborhood city state latitude longitude _destroy
                         ],
                         group_ids: [],
                         speciality_ids: [],
                         specialization_ids: [] }]
      )

      Rails.logger.info "Parâmetros permitidos: #{permitted_params.inspect}"
      permitted_params
    end

    def load_form_data
      @contract_types = ContractType.active.ordered
      @groups = Group.ordered
      @specialities = Speciality.active.ordered
    end

    def has_future_appointments?
      @professional.medical_appointments.where('scheduled_at > ?', Time.current).exists?
    end
  end
end
