# frozen_string_literal: true

module Portal
  class SessionsController < ApplicationController
    layout 'auth'

    def new
      @external_user = ExternalUser.new
    end

    def create
      login_params = external_user_params
      user = ExternalUser.find_by(email: login_params[:email])

      if user&.active? && user.valid_password?(login_params[:password])
        session[:external_user_id] = user.id
        redirect_to portal_root_path, notice: 'Login realizado com sucesso!'
      else
        @external_user = ExternalUser.new(email: login_params[:email])
        flash.now[:alert] = 'Email ou senha inválidos.'
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session[:external_user_id] = nil
      redirect_to portal_new_external_user_session_path, notice: 'Logout realizado com sucesso!'
    end

    private

    def external_user_params
      params.expect(external_user: %i[email password remember_me])
    end
  end
end
