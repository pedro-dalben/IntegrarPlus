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
        session[:external_user_last_seen_at] = Time.current.iso8601
        redirect_to portal_root_path, notice: 'Login realizado com sucesso!'
      else
        @external_user = ExternalUser.new(email: login_params[:email])
        flash.now[:alert] = 'Email ou senha inválidos.'
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session[:external_user_id] = nil
      session[:external_user_last_seen_at] = nil
      redirect_to portal_new_external_user_session_path, notice: 'Logout realizado com sucesso!'
    end

    private

    def external_user_params
      permitted_fields = %i[email password]
      permitted_fields << :remember_me unless Rails.env.production?

      params.expect(external_user: permitted_fields)
    end
  end
end
