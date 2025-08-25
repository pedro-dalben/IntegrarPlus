# frozen_string_literal: true

require 'ostruct'

module Admin
  class SpecializationsController < Admin::BaseController
    before_action :set_specialization, only: %i[show edit update destroy]
    before_action :set_specialities, only: %i[new edit]

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
    end

    def edit; end

    def create
      @specialization = Specialization.new(specialization_params)

      if @specialization.save
        redirect_to admin_specialization_path(@specialization), notice: 'Especialização criada com sucesso.'
      else
        set_specialities
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @specialization.update(specialization_params)
        redirect_to admin_specialization_path(@specialization), notice: 'Especialização atualizada com sucesso.'
      else
        set_specialities
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @specialization.destroy
      redirect_to admin_specializations_path, notice: 'Especialização excluída com sucesso.'
    end

    def by_speciality
      speciality_ids = params[:speciality_ids]&.split(',')&.map(&:to_i) || []

      @specializations = if speciality_ids.any?
                           Specialization.joins(:specialities).where(specialities: { id: speciality_ids })
                         else
                           Specialization.none
                         end

      render json: @specializations.map { |s| { id: s.id, name: s.name } }
    end

    private

    def set_specialization
      @specialization = Specialization.find(params[:id])
    end

    def set_specialities
      @specialities = Speciality.all.order(:name)
    end

    def specialization_params
      params.require(:specialization).permit(:name, speciality_ids: [])
    end
  end
end
