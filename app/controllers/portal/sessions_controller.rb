# frozen_string_literal: true

module Portal
  class SessionsController < ApplicationController
    layout 'auth'

    def new
      @external_user = ExternalUser.new
    end

    def create
      @external_user = ExternalUser.find_by(email: params[:external_user][:email])

      if @external_user&.active? && @external_user.valid_password?(params[:external_user][:password])
        session[:external_user_id] = @external_user.id
        redirect_to portal_root_path, notice: 'Login realizado com sucesso!'
      else
        flash.now[:alert] = 'Email ou senha inválidos.'
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session[:external_user_id] = nil
      redirect_to new_external_user_session_path, notice: 'Logout realizado com sucesso!'
    end

    private

    def external_user_params
      params.require(:external_user).permit(:email, :password, :remember_me)
    end
  end
end
