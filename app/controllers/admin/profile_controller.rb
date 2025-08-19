# frozen_string_literal: true

module Admin
  class ProfileController < BaseController
    def show
      @user = current_user
    end

    def edit
      @user = current_user
    end

    def update
      @user = current_user

      if @user.update(user_params)
        redirect_to admin_profile_path, notice: 'Perfil atualizado com sucesso!'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:name, :email, :avatar)
    end
  end
end
