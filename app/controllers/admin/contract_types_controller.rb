# frozen_string_literal: true

module Admin
  class ContractTypesController < BaseController
    before_action :set_contract_type, only: %i[show edit update destroy]

    def index
      if params[:query].present?
        @pagy, @contract_types = pagy_meilisearch(ContractType, query: params[:query], limit: 10)
      else
        @pagy, @contract_types = pagy(ContractType.all, limit: 10)
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

    def set_contract_type
      @contract_type = ContractType.find(params[:id])
    end

    def contract_type_params
      params.require(:contract_type).permit(:name, :description, :requires_company, :requires_cnpj, :active)
    end
  end
end
