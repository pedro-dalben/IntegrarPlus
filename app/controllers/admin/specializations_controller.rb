# frozen_string_literal: true

module Admin
  class SpecializationsController < Admin::BaseController
    before_action :set_specialization, only: %i[show edit update destroy]

    def index
      @pagy, @specializations = if params[:query].present?
                                  pagy(Specialization.search(params[:query]), limit: 10)
                                else
                                  pagy(Specialization.all, limit: 10)
                                end
    end

    def show; end

    def new
      @specialization = Specialization.new
    end

    def edit; end

    def create
      @specialization = Specialization.new(specialization_params)

      if @specialization.save
        redirect_to admin_specialization_path(@specialization), notice: 'Especialização criada com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @specialization.update(specialization_params)
        redirect_to admin_specialization_path(@specialization), notice: 'Especialização atualizada com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @specialization.destroy
      redirect_to admin_specializations_path, notice: 'Especialização excluída com sucesso.'
    end

    private

    def set_specialization
      @specialization = Specialization.find(params[:id])
    end

    def specialization_params
      params.require(:specialization).permit(:name, :speciality_id)
    end
  end
end
