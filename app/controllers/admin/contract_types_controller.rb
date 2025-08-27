# frozen_string_literal: true

module Admin
  class ContractTypesController < BaseController
    before_action :set_contract_type, only: %i[show edit update destroy]

    def index
      if params[:query].present?
        begin
          search_service = AdvancedSearchService.new(ContractType)
          filters = build_search_filters
          options = build_search_options

          search_results = search_service.search(params[:query], filters, options)

          page = (params[:page] || 1).to_i
          per_page = 10
          offset = (page - 1) * per_page

          @contract_types = search_results[offset, per_page] || []
          @pagy = Pagy.new(count: search_results.length, page: page, items: per_page)
        rescue StandardError => e
          Rails.logger.error "Erro na busca avançada: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          @contract_types = perform_local_search
          @pagy, @contract_types = pagy(@contract_types, items: 10)
        end
      else
        @contract_types = perform_local_search
        @pagy, @contract_types = pagy(@contract_types, items: 10)
      end

      return unless request.xhr?

      render partial: 'table', locals: { contract_types: @contract_types, pagy: @pagy }, layout: false
    end

    def show; end

    def new
      @contract_type = ContractType.new
      authorize @contract_type, :create?
    end

    def edit
      authorize @contract_type, :update?
    end

    def create
      @contract_type = ContractType.new(contract_type_params)
      authorize @contract_type, :create?

      if @contract_type.save
        redirect_to admin_contract_type_path(@contract_type), notice: 'Tipo de contrato criado com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @contract_type, :update?

      if @contract_type.update(contract_type_params)
        redirect_to admin_contract_type_path(@contract_type), notice: 'Tipo de contrato atualizado com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @contract_type, :destroy?

      if @contract_type.destroy
        redirect_to admin_contract_types_path, notice: 'Tipo de contrato excluído com sucesso.'
      else
        redirect_to admin_contract_types_path, alert: 'Não foi possível remover o tipo de contrato.'
      end
    end

    private

    def perform_local_search
      ContractType.order(created_at: :desc)
    end

    def build_search_filters
      filters = {}

      # Filtros adicionais podem ser adicionados aqui
      if params[:active].present?
        filters[:active] = params[:active] == 'true'
      end

      if params[:requires_company].present?
        filters[:requires_company] = params[:requires_company] == 'true'
      end

      if params[:requires_cnpj].present?
        filters[:requires_cnpj] = params[:requires_cnpj] == 'true'
      end

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
      when 'name'
        "name:#{direction}"
      when 'created_at'
        "created_at:#{direction}"
      when 'updated_at'
        "updated_at:#{direction}"
      else
        'created_at:desc'
      end
    end

    def set_contract_type
      @contract_type = ContractType.find(params[:id])
    end

    def contract_type_params
      params.require(:contract_type).permit(:name, :description, :requires_company, :requires_cnpj, :active)
    end
  end
end
