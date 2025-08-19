# frozen_string_literal: true

module Admin
  class ProfessionalsController < BaseController
    before_action :set_professional, only: [:show, :edit, :update, :destroy]

    def index
      @pagy, @professionals = if params[:query].present?
        pagy(Professional.search(params[:query]))
      else
        pagy(Professional.all)
      end
    end

    def show
    end

    def new
      @professional = Professional.new
    end

    def edit
    end

    def create
      @professional = Professional.new(professional_params)

      if @professional.save
        redirect_to admin_professional_path(@professional), notice: 'Profissional criado com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @professional.update(professional_params)
        redirect_to admin_professional_path(@professional), notice: 'Profissional atualizado com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @professional.destroy
      redirect_to admin_professionals_path, notice: 'Profissional excluído com sucesso.'
    end

    private

    def set_professional
      @professional = Professional.find(params[:id])
    end

    def professional_params
      params.require(:professional).permit(:name, :email, :phone, :speciality_id, :contract_type_id, :active)
    end
  end
end
