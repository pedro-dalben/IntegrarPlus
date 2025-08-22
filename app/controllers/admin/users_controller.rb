module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy activate deactivate]

    def index
      redirect_to admin_professionals_path,
                  notice: t('admin.users.messages.redirect_notice')
    end

    def show
      @invites = @user.invites.order(created_at: :desc)
    end

    def edit; end

    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: t('admin.users.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_professionals_path, notice: t('admin.users.messages.deleted')
    end

    def activate
      if @user.professional
        @user.professional.update!(active: true)
        redirect_to admin_user_path(@user), notice: t('admin.users.messages.activated')
      else
        redirect_to admin_user_path(@user), alert: t('admin.users.messages.no_professional')
      end
    end

    def deactivate
      if @user.professional
        @user.professional.update!(active: false)
        redirect_to admin_user_path(@user), notice: t('admin.users.messages.deactivated')
      else
        redirect_to admin_user_path(@user), alert: t('admin.users.messages.no_professional')
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
