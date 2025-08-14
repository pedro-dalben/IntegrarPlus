# frozen_string_literal: true

module Admin
  class SpecializationsController < Admin::BaseController
    before_action :set_specialization, only: %i[edit update destroy]

    def index
      respond_to do |format|
        format.html do
          authorize Specialization, :index?
          @specializations = Specialization.includes(:speciality).ordered
        end
        format.json do
          authorize Specialization, :index?
          speciality_ids = params[:speciality_ids]&.map(&:to_i) || []

          specializations = if speciality_ids.any?
                              Specialization.by_speciality(speciality_ids).ordered
                            else
                              Specialization.none
                            end

          render json: specializations.map { |s| { id: s.id, name: s.name, speciality_id: s.speciality_id } }
        end
      end
    end

    def new
      @specialization = Specialization.new
      authorize @specialization, :create?
      @specialities = Speciality.ordered
    end

    def edit
      authorize @specialization, :update?
      @specialities = Speciality.ordered
    end

    def create
      @specialization = Specialization.new(specialization_params)
      authorize @specialization, :create?

      if @specialization.save
        redirect_to admin_specializations_path, notice: 'Especialização criada com sucesso.'
      else
        @specialities = Speciality.ordered
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @specialization, :update?

      if @specialization.update(specialization_params)
        redirect_to admin_specializations_path, notice: 'Especialização atualizada com sucesso.'
      else
        @specialities = Speciality.ordered
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @specialization, :destroy?

      if @specialization.destroy
        redirect_to admin_specializations_path, notice: 'Especialização removida com sucesso.'
      else
        redirect_to admin_specializations_path, alert: 'Não foi possível remover a especialização.'
      end
    end

    private

    def set_specialization
      @specialization = Specialization.find(params[:id])
    end

    def specialization_params
      params.expect(specialization: %i[name speciality_id])
    end
  end
end
