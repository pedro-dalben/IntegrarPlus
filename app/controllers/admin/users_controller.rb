module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :edit, :update, :destroy, :activate, :deactivate]

    def index
      @users = User.includes(:professional, :invites)
                   .order(:name)
      
      @users = @users.where("users.name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
      
      case params[:status]
      when 'active'
        @users = @users.joins(:professional).where(professionals: { active: true })
      when 'pending'
        @users = @users.joins(:invites).where(invites: { confirmed_at: nil }).where('invites.expires_at > ?', Time.current)
      when 'inactive'
        @users = @users.joins(:professional).where(professionals: { active: false })
      when 'expired'
        @users = @users.joins(:invites).where(invites: { confirmed_at: nil }).where('invites.expires_at <= ?', Time.current)
      end
      
      @users = @users.page(params[:page])
    end

    def show
      @invites = @user.invites.order(created_at: :desc)
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: 'Usuário atualizado com sucesso.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: 'Usuário removido com sucesso.'
    end

    def activate
      if @user.professional
        @user.professional.update!(active: true)
        redirect_to admin_user_path(@user), notice: 'Usuário ativado com sucesso.'
      else
        redirect_to admin_user_path(@user), alert: 'Usuário não possui profissional associado.'
      end
    end

    def deactivate
      if @user.professional
        @user.professional.update!(active: false)
        redirect_to admin_user_path(@user), notice: 'Usuário desativado com sucesso.'
      else
        redirect_to admin_user_path(@user), alert: 'Usuário não possui profissional associado.'
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email)
    end
  end
end
