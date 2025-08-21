# frozen_string_literal: true

require 'ostruct'

module Admin
  class SpecialitiesController < BaseController
    before_action :set_speciality, only: %i[show edit update destroy]

    def index
      if params[:query].present?
        search_results = Speciality.search(params[:query])
        page = (params[:page] || 1).to_i
        per_page = 10
        offset = (page - 1) * per_page

        @specialities = search_results[offset, per_page] || []
        @pagy = OpenStruct.new(
          count: search_results.length,
          page: page,
          items: per_page,
          pages: (search_results.length.to_f / per_page).ceil,
          from: offset + 1,
          to: [offset + per_page, search_results.length].min,
          prev: page > 1 ? page - 1 : nil,
          next: page < (search_results.length.to_f / per_page).ceil ? page + 1 : nil,
          series: []
        )
      else
        @pagy, @specialities = pagy(Speciality.all, limit: 10)
      end

      return unless request.xhr?

      render partial: 'table', locals: { specialities: @specialities, pagy: @pagy }, layout: false
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

    def set_speciality
      @speciality = Speciality.find(params[:id])
    end

    def speciality_params
      params = params.require(:speciality).permit(:name, :active)
      params[:specialty] = params[:name] if params[:name].present?
      params
    end
  end
end
