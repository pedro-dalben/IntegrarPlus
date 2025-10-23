# frozen_string_literal: true

module Admin
  class SpecialitiesController < BaseController
    before_action :set_speciality, only: %i[show edit update destroy]

    def index
      if params[:query].present?
        begin
          search_service = AdvancedSearchService.new(Speciality)
          filters = build_search_filters
          options = build_search_options

          search_results = search_service.search(params[:query], filters, options)

          page = (params[:page] || 1).to_i
          per_page = 10
          offset = (page - 1) * per_page

          @specialities = search_results[offset, per_page] || []
          @pagy = Pagy.new(count: search_results.length, page: page, items: per_page)
        rescue StandardError => e
          Rails.logger.error "Erro na busca avançada: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          @specialities = perform_local_search
          @pagy, @specialities = pagy(@specialities, items: 10)
        end
      else
        @specialities = perform_local_search
        @pagy, @specialities = pagy(@specialities, items: 10)
      end

      respond_to do |format|
        format.html do
          render partial: 'search_results', layout: false if request.xhr?
        end
        format.json { render json: { results: @specialities, count: @pagy.count } }
      end
    end

    def show; end

    def new
      @speciality = Speciality.new
      authorize @speciality, :create?
    end

    def edit
      authorize @speciality, :update?
    end

    def create
      @speciality = Speciality.new(speciality_params)
      authorize @speciality, :create?

      if @speciality.save
        redirect_to admin_speciality_path(@speciality), notice: 'Especialidade criada com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @speciality, :update?

      if @speciality.update(speciality_params)
        redirect_to admin_speciality_path(@speciality), notice: 'Especialidade atualizada com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @speciality, :destroy?

      if @speciality.destroy
        redirect_to admin_specialities_path, notice: 'Especialidade excluída com sucesso.'
      else
        redirect_to admin_specialities_path, alert: 'Não foi possível remover a especialidade.'
      end
    end

    private

    def perform_local_search
      Speciality.order(created_at: :desc)
    end

    def build_search_filters
      filters = {}

      # Filtros adicionais podem ser adicionados aqui
      filters[:active] = params[:active] == 'true' if params[:active].present?

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

    def set_speciality
      @speciality = Speciality.find(params[:id])
    end

    def speciality_params
      permitted_params = params.expect(speciality: %i[name active])
      permitted_params[:specialty] = permitted_params[:name] if permitted_params[:name].present?
      permitted_params
    end
  end
end
