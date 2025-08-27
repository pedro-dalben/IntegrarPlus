# frozen_string_literal: true

require 'ostruct'

module Admin
  class GroupsController < BaseController
    before_action :set_group, only: %i[show edit update destroy]

    def index
      if params[:query].present?
        begin
          search_service = AdvancedSearchService.new(Group)
          filters = build_search_filters
          options = build_search_options

          search_results = search_service.search(params[:query], filters, options)

          page = (params[:page] || 1).to_i
          per_page = 10
          offset = (page - 1) * per_page

          @groups = search_results[offset, per_page] || []
          @pagy = Pagy.new(count: search_results.length, page: page, items: per_page)
        rescue StandardError => e
          Rails.logger.error "Erro na busca avançada: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          @groups = perform_local_search
          @pagy, @groups = pagy(@groups, items: 10)
        end
      else
        @groups = perform_local_search
        @pagy, @groups = pagy(@groups, items: 10)
      end

      return unless request.xhr?

      render partial: 'table', locals: { groups: @groups, pagy: @pagy }, layout: false
    end

    def show; end

    def new
      @group = Group.new
      @permissions = Permission.ordered
    end

    def edit
      @permissions = Permission.ordered
    end

    def create
      @group = Group.new(group_params)

      if @group.save
        redirect_to admin_group_path(@group), notice: 'Grupo criado com sucesso.'
      else
        @permissions = Permission.ordered
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @group.update(group_params)
        redirect_to admin_group_path(@group), notice: 'Grupo atualizado com sucesso.'
      else
        @permissions = Permission.ordered
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @group.destroy
      redirect_to admin_groups_path, notice: 'Grupo excluído com sucesso.'
    end

    def search
      query = params[:q]
      groups = Group.where('name ILIKE ?', "%#{query}%")
                    .limit(10)
                    .map { |group| { id: group.id, name: group.name } }

      render json: groups
    end

    private

    def perform_local_search
      Group.includes(:permissions).order(created_at: :desc)
    end

    def build_search_filters
      filters = {}

      # Filtros adicionais podem ser adicionados aqui
      if params[:is_admin].present?
        filters[:is_admin] = params[:is_admin] == 'true'
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

    def set_group
      @group = Group.find(params[:id])
    end

    def group_params
      params.expect(group: [:name, :description, :is_admin, { permission_ids: [] }])
    end
  end
end
