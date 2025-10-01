# frozen_string_literal: true

module Admin
  class BeneficiariesController < BaseController
    before_action :set_beneficiary, only: %i[show edit update destroy]

    def index
      if params[:query].present?
        begin
          search_service = AdvancedSearchService.new(Beneficiary)
          filters = build_search_filters
          options = build_search_options

          search_results = search_service.search(params[:query], filters, options)

          page = (params[:page] || 1).to_i
          per_page = 20
          offset = (page - 1) * per_page

          @beneficiaries = search_results[offset, per_page] || []
          @pagy = Pagy.new(count: search_results.length, page: page, items: per_page)
        rescue StandardError => e
          Rails.logger.error "Erro na busca avançada: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          @beneficiaries = perform_local_search
          @pagy, @beneficiaries = pagy(@beneficiaries, items: 20)
        end
      else
        @beneficiaries = perform_local_search
        @pagy, @beneficiaries = pagy(@beneficiaries, items: 20)
      end

      respond_to do |format|
        format.html do
          render partial: 'search_results', layout: false if request.xhr?
        end
        format.json { render json: { results: @beneficiaries, count: @pagy.count } }
      end
    end

    def show
      authorize @beneficiary, policy_class: Admin::BeneficiaryPolicy
      @anamneses = @beneficiary.anamneses.recent
      @medical_appointments = @beneficiary.medical_appointments.recent
    end

    def new
      @beneficiary = Beneficiary.new
      authorize @beneficiary, policy_class: Admin::BeneficiaryPolicy
    end

    def edit
      authorize @beneficiary, policy_class: Admin::BeneficiaryPolicy
    end

    def create
      @beneficiary = Beneficiary.new(beneficiary_params)
      @beneficiary.created_by_professional = current_user
      authorize @beneficiary, policy_class: Admin::BeneficiaryPolicy

      if @beneficiary.save
        redirect_to admin_beneficiary_path(@beneficiary), notice: 'Beneficiário criado com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @beneficiary, policy_class: Admin::BeneficiaryPolicy
      @beneficiary.updated_by_professional = current_user

      if @beneficiary.update(beneficiary_params)
        redirect_to admin_beneficiary_path(@beneficiary), notice: 'Beneficiário atualizado com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @beneficiary, policy_class: Admin::BeneficiaryPolicy

      if @beneficiary.pode_ser_excluido?
        @beneficiary.destroy
        redirect_to admin_beneficiaries_path, notice: 'Beneficiário excluído com sucesso.'
      else
        redirect_to admin_beneficiaries_path,
                    alert: 'Não é possível excluir beneficiário com anamneses ou agendamentos associados.'
      end
    end

    def search
      query = params[:q]
      beneficiaries = Beneficiary.search_by_term(query)
                                 .limit(10)
                                 .map do |beneficiary|
        { id: beneficiary.id, name: beneficiary.name,
          integrar_code: beneficiary.integrar_code }
      end

      render json: beneficiaries
    end

    private

    def set_beneficiary
      @beneficiary = Beneficiary.find(params[:id])
    end

    def perform_local_search
      scope = Beneficiary.includes(:anamneses, :medical_appointments, :portal_intake)

      scope = apply_filters(scope)
      scope = scope.ordered
    end

    def build_search_filters
      filters = {}

      filters[:status] = params[:status] if params[:status].present?
      filters[:created_at] = params[:created_at] if params[:created_at].present?

      filters
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

      case order_by
      when 'nome'
        "nome:#{direction}"
      when 'data_nascimento'
        "data_nascimento:#{direction}"
      when 'created_at'
        "created_at:#{direction}"
      when 'updated_at'
        "updated_at:#{direction}"
      else
        'created_at:desc'
      end
    end

    def apply_filters(scope)
      scope = scope.by_status(params[:status]) if params[:status].present?
      scope = scope.by_name(params[:name]) if params[:name].present?
      scope = scope.by_cpf(params[:cpf]) if params[:cpf].present?

      if params[:start_date].present? && params[:end_date].present?
        begin
          start_date = Date.parse(params[:start_date])
          end_date = Date.parse(params[:end_date])
          scope = scope.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
        rescue Date::Error
          # Ignora filtro de data se inválido
        end
      end

      if params[:min_age].present? && params[:max_age].present?
        begin
          min_age = params[:min_age].to_i
          max_age = params[:max_age].to_i
          scope = scope.by_age_range(min_age, max_age)
        rescue StandardError
          # Ignora filtro de idade se inválido
        end
      end

      scope
    end

    def beneficiary_params
      params.expect(
        beneficiary: %i[
          name birth_date cpf phone secondary_phone email secondary_email whatsapp_number
          address address_number address_complement neighborhood city state zip_code address_reference
          responsible_name responsible_phone relationship responsible_cpf responsible_rg
          responsible_profession family_income attends_school school_name school_period
          health_plan health_card_number allergies continuous_medications special_conditions
          medical_record_number photo status treatment_start_date treatment_end_date inactivation_reason
          portal_intake_id
        ]
      )
    end
  end
end
