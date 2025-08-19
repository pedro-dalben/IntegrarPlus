# frozen_string_literal: true

module Admin
  class ContractTypesController < BaseController
    before_action :set_contract_type, only: %i[show edit update destroy]

    def index
      @pagy, @contract_types = if params[:query].present?
        pagy(ContractType.search(params[:query]))
      else
        pagy(ContractType.all)
      end
    end

    def show; end

    def new
      @contract_type = ContractType.new
    end

    def edit; end

    def create
      @contract_type = ContractType.new(contract_type_params)

      if @contract_type.save
        redirect_to admin_contract_type_path(@contract_type), notice: 'Tipo de contrato criado com sucesso.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @contract_type.update(contract_type_params)
        redirect_to admin_contract_type_path(@contract_type), notice: 'Tipo de contrato atualizado com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @contract_type.destroy
      redirect_to admin_contract_types_path, notice: 'Tipo de contrato excluído com sucesso.'
    end

    private

    def set_contract_type
      @contract_type = ContractType.find(params[:id])
    end

    def contract_type_params
      params.require(:contract_type).permit(:description, :active)
    end
  end
end
