# frozen_string_literal: true

module Admin
  class ProfessionalsController < BaseController
    before_action :set_professional, only: %i[show edit update destroy create_user toggle_active
                                               generate_contract_pdf generate_anexo_pdf generate_termo_pdf
                                               download_contract_pdf download_anexo_pdf download_termo_pdf]

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

    def generate_contract_pdf
      @professional.create_professional_contract unless @professional.professional_contract
      contract = @professional.professional_contract

      unless contract.present?
        redirect_to admin_professional_path(@professional),
                    alert: 'Contrato não encontrado. Preencha os dados contratuais primeiro.'
        return
      end

      pdf_service = ContractPdfService.new
      pdf_service.save_contract_pdf(contract)

      redirect_to admin_professional_path(@professional),
                  notice: 'Contrato gerado com sucesso!'
    rescue StandardError => e
      Rails.logger.error "Erro ao gerar contrato: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to admin_professional_path(@professional),
                  alert: "Erro ao gerar contrato: #{e.message}"
    end

    def generate_anexo_pdf
      @professional.create_professional_contract unless @professional.professional_contract
      contract = @professional.professional_contract

      unless contract&.job_role.present?
        redirect_to admin_professional_path(@professional),
                    alert: 'Atribuição de cargo não selecionada. Selecione um cargo nos dados contratuais.'
        return
      end

      pdf_service = ContractPdfService.new
      pdf_service.save_anexo_pdf(contract)

      redirect_to admin_professional_path(@professional),
                  notice: 'Anexo I gerado com sucesso!'
    rescue StandardError => e
      Rails.logger.error "Erro ao gerar anexo: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to admin_professional_path(@professional),
                  alert: "Erro ao gerar anexo: #{e.message}"
    end

    def generate_termo_pdf
      @professional.create_professional_contract unless @professional.professional_contract
      contract = @professional.professional_contract

      unless contract.present?
        redirect_to admin_professional_path(@professional),
                    alert: 'Contrato não encontrado. Preencha os dados contratuais primeiro.'
        return
      end

      pdf_service = ContractPdfService.new
      pdf_service.save_termo_pdf(contract)

      redirect_to admin_professional_path(@professional),
                  notice: 'Termo de Imagem gerado com sucesso!'
    rescue StandardError => e
      Rails.logger.error "Erro ao gerar termo: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to admin_professional_path(@professional),
                  alert: "Erro ao gerar termo: #{e.message}"
    end

    def download_contract_pdf
      contract = @professional.professional_contract
      unless contract&.contract_pdf_path.present?
        redirect_to admin_professional_path(@professional),
                    alert: 'Contrato ainda não foi gerado.'
        return
      end

      file_path = Rails.root.join('storage', contract.contract_pdf_path)
      unless File.exist?(file_path)
        redirect_to admin_professional_path(@professional),
                    alert: 'Arquivo do contrato não encontrado.'
        return
      end

      send_file file_path, filename: "contrato_#{@professional.full_name.parameterize}.pdf",
                type: 'application/pdf', disposition: 'attachment'
    end

    def download_anexo_pdf
      contract = @professional.professional_contract
      unless contract&.anexo_pdf_path.present?
        redirect_to admin_professional_path(@professional),
                    alert: 'Anexo I ainda não foi gerado.'
        return
      end

      file_path = Rails.root.join('storage', contract.anexo_pdf_path)
      unless File.exist?(file_path)
        redirect_to admin_professional_path(@professional),
                    alert: 'Arquivo do anexo não encontrado.'
        return
      end

      send_file file_path, filename: "anexo_i_#{@professional.full_name.parameterize}.pdf",
                type: 'application/pdf', disposition: 'attachment'
    end

    def download_termo_pdf
      contract = @professional.professional_contract
      unless contract&.termo_pdf_path.present?
        redirect_to admin_professional_path(@professional),
                    alert: 'Termo de Imagem ainda não foi gerado.'
        return
      end

      file_path = Rails.root.join('storage', contract.termo_pdf_path)
      unless File.exist?(file_path)
        redirect_to admin_professional_path(@professional),
                    alert: 'Arquivo do termo não encontrado.'
        return
      end

      send_file file_path, filename: "termo_imagem_#{@professional.full_name.parameterize}.pdf",
                type: 'application/pdf', disposition: 'attachment'
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
      Professional.order(created_at: :desc)
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
                         professional_contract_attributes: %i[
                           id contract_type_enum nationality professional_formation
                           rg cpf council_registration_number job_role_id
                           payment_type monthly_value hourly_value overtime_hour_value
                           company_cnpj company_address company_represented_by
                           ccm taxpayer_address _destroy
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
      @job_roles = JobRole.active.ordered
    end

    def has_future_appointments?
      @professional.medical_appointments.exists?(['scheduled_at > ?', Time.current])
    end
  end
end
