class Admin::SpecialitiesController < Admin::BaseController
  before_action :set_speciality, only: %i[edit update destroy]

  def index
    authorize Speciality, :index?
    @specialities = Speciality.ordered
  end

  def new
    @speciality = Speciality.new
    authorize @speciality, :create?
  end

  def create
    @speciality = Speciality.new(speciality_params)
    authorize @speciality, :create?

    if @speciality.save
      redirect_to admin_specialities_path, notice: 'Especialidade criada com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @speciality, :update?
  end

  def update
    authorize @speciality, :update?

    if @speciality.update(speciality_params)
      redirect_to admin_specialities_path, notice: 'Especialidade atualizada com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @speciality, :destroy?

    if @speciality.destroy
      redirect_to admin_specialities_path, notice: 'Especialidade removida com sucesso.'
    else
      redirect_to admin_specialities_path, alert: 'Não foi possível remover a especialidade.'
    end
  end

  private

  def set_speciality
    @speciality = Speciality.find(params[:id])
  end

  def speciality_params
    params.require(:speciality).permit(:name)
  end
end
