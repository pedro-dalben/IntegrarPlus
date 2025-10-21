# frozen_string_literal: true

module Admin
  class SpecializationsController < BaseController
    before_action :set_specialization, only: %i[show edit update destroy]

    def index
      if params[:query].present?
        begin
          search_service = AdvancedSearchService.new(Specialization)
          filters = build_search_filters
          options = build_search_options

          search_results = search_service.search(params[:query], filters, options)

          page = (params[:page] || 1).to_i
          per_page = 10
          offset = (page - 1) * per_page

          @specializations = search_results[offset, per_page] || []
          @pagy = Pagy.new(count: search_results.length, page: page, items: per_page)
        rescue StandardError => e
          Rails.logger.error "Erro na busca avançada: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          @specializations = perform_local_search
          @pagy, @specializations = pagy(@specializations, items: 10)
        end
      else
        @specializations = perform_local_search
        @pagy, @specializations = pagy(@specializations, items: 10)
      end

      respond_to do |format|
        format.html do
          render partial: 'search_results', layout: false if request.xhr?
        end
        format.json { render json: { results: @specializations, count: @pagy.count } }
      end
    end

    def by_speciality
      speciality_ids = params[:speciality_ids] || []

      Rails.logger.info "Buscando especializações para especialidades: #{speciality_ids}"

      if speciality_ids.empty?
        Rails.logger.info 'Nenhuma especialidade selecionada, retornando array vazio'
        render json: []
        return
      end

      begin
        specializations = Specialization.joins(:specialities)
                                        .where(specialities: { id: speciality_ids })
                                        .includes(:specialities)
                                        .order(:name)

        Rails.logger.info "Encontradas #{specializations.count} especializações"

        result = specializations.map do |spec|
          {
            id: spec.id,
            name: spec.name,
            speciality_name: spec.specialities.first&.name || 'N/A'
          }
        end

        Rails.logger.info "Resultado: #{result.inspect}"
        render json: result
      rescue StandardError => e
        Rails.logger.error "Erro ao buscar especializações: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: 'Erro interno do servidor' }, status: :internal_server_error
      end
    end

    def show; end

    def new
      @specialization = Specialization.new
      @specialities = Speciality.order(:name)
      authorize @specialization, :create?
    end

    def edit
      @specialities = Speciality.order(:name)
      authorize @specialization, :update?
    end

    def create
      @specialization = Specialization.new(specialization_params)
      authorize @specialization, :create?

      if @specialization.save
        redirect_to admin_specialization_path(@specialization), notice: 'Especialização criada com sucesso.'
      else
        @specialities = Speciality.order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @specialization, :update?

      if @specialization.update(specialization_params)
        redirect_to admin_specializations_path, notice: 'Especialização atualizada com sucesso.'
      else
        @specialities = Speciality.order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @specialization, :destroy?

      if @specialization.destroy
        redirect_to admin_specializations_path, notice: 'Especialização excluída com sucesso.'
      else
        redirect_to admin_specializations_path, alert: 'Não foi possível remover a especialização.'
      end
    end

    private

    def perform_local_search
      Specialization.includes(:specialities).order(created_at: :desc)
    end

    def build_search_filters
      filters = {}

      # Filtros adicionais podem ser adicionados aqui
      filters[:speciality_id] = params[:speciality_id] if params[:speciality_id].present?

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

    def set_specialization
      @specialization = Specialization.find(params[:id])
    end

    def specialization_params
      params.expect(specialization: [:name, { speciality_ids: [] }])
    end
  end
end
