class Admin::ContractTypesController < Admin::BaseController
  before_action :set_contract_type, only: %i[edit update destroy]

  def index
    authorize ContractType, :index?
    @contract_types = ContractType.ordered
  end

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
      redirect_to admin_contract_types_path, notice: 'Forma de contratação criada com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @contract_type, :update?

    if @contract_type.update(contract_type_params)
      redirect_to admin_contract_types_path, notice: 'Forma de contratação atualizada com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @contract_type, :destroy?

    if @contract_type.destroy
      redirect_to admin_contract_types_path, notice: 'Forma de contratação removida com sucesso.'
    else
      redirect_to admin_contract_types_path, alert: 'Não foi possível remover a forma de contratação.'
    end
  end

  private

  def set_contract_type
    @contract_type = ContractType.find(params[:id])
  end

  def contract_type_params
    params.require(:contract_type).permit(:name, :requires_company, :requires_cnpj, :description)
  end
end
