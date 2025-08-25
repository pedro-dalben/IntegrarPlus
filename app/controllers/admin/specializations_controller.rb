# frozen_string_literal: true

module Admin
  class SpecializationsController < BaseController
    before_action :set_specialization, only: %i[show edit update destroy]

    def index
      if params[:query].present?
        @pagy, @specializations = pagy_meilisearch(Specialization, query: params[:query], limit: 10)
      else
        @pagy, @specializations = pagy(Specialization.all, limit: 10)
      end

      return unless request.xhr?

      render partial: 'table', locals: { specializations: @specializations, pagy: @pagy }, layout: false
    end

    def show; end

    def new
      @specialization = Specialization.new
      authorize @specialization, :create?
    end

    def edit
      authorize @specialization, :update?
    end

    def create
      @specialization = Specialization.new(specialization_params)
      authorize @specialization, :create?

      if @specialization.save
        redirect_to admin_specialization_path(@specialization), notice: 'Especialização criada com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @specialization, :update?

      if @specialization.update(specialization_params)
        redirect_to admin_specialization_path(@specialization), notice: 'Especialização atualizada com sucesso.'
      else
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

    def set_specialization
      @specialization = Specialization.find(params[:id])
    end

    def specialization_params
      params.expect(specialization: [:name, { speciality_ids: [] }])
    end
  end
end
