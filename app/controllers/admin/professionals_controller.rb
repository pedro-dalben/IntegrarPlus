class Admin::ProfessionalsController < Admin::BaseController
  before_action :set_professional, only: [:show, :edit, :update, :destroy, :resend_confirmation, :send_reset_password, :force_confirm]

  def index
    authorize Professional, :index?
    @professionals = Professional.includes(:contract_type, :groups, :specialities).ordered
  end

  def show
    authorize @professional, :show?
  end

  def new
    @professional = Professional.new
    authorize @professional, :create?
    load_form_data
  end

  def create
    @professional = Professional.new(professional_params)
    authorize @professional, :create?

    if @professional.save
      redirect_to admin_professional_path(@professional), notice: 'Profissional criado com sucesso.'
    else
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @professional, :update?
    load_form_data
  end

  def update
    authorize @professional, :update?

    if @professional.update(professional_params)
      redirect_to admin_professional_path(@professional), notice: 'Profissional atualizado com sucesso.'
    else
      load_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @professional, :destroy?

    if @professional.destroy
      redirect_to admin_professionals_path, notice: 'Profissional removido com sucesso.'
    else
      redirect_to admin_professional_path(@professional), alert: 'Não foi possível remover o profissional.'
    end
  end

  def resend_confirmation
    authorize @professional, :manage?

    if @professional.confirmation_sent_at.nil? || @professional.confirmation_sent_at < 1.hour.ago
      @professional.send_confirmation_instructions
      redirect_to admin_professional_path(@professional), notice: 'E-mail de confirmação reenviado com sucesso.'
    else
      redirect_to admin_professional_path(@professional), alert: 'Aguarde pelo menos 1 hora para reenviar o e-mail de confirmação.'
    end
  end

  def send_reset_password
    authorize @professional, :manage?

    @professional.send_reset_password_instructions
    redirect_to admin_professional_path(@professional), notice: 'E-mail de redefinição de senha enviado com sucesso.'
  end

  def force_confirm
    authorize @professional, :manage?

    if @professional.confirm
      redirect_to admin_professional_path(@professional), notice: 'Profissional confirmado com sucesso.'
    else
      redirect_to admin_professional_path(@professional), alert: 'Não foi possível confirmar o profissional.'
    end
  end

  private

  def set_professional
    @professional = Professional.find(params[:id])
  end

  def load_form_data
    @contract_types = ContractType.ordered
    @groups = Group.ordered
    @specialities = Speciality.ordered
  end

  def professional_params
    params.require(:professional).permit(
      :full_name, :birth_date, :cpf, :phone, :email, :active,
      :contract_type_id, :hired_on, :workload_minutes, :council_code,
      :company_name, :cnpj, :password, :password_confirmation,
      group_ids: [], speciality_ids: [], specialization_ids: []
    )
  end
end
