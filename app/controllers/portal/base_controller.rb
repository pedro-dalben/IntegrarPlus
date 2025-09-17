# frozen_string_literal: true

module Portal
  class BaseController < ApplicationController
    layout 'portal'

    before_action :authenticate_external_user!
    # before_action :check_external_user_active

    helper_method :current_external_user

    def current_external_user
      return @current_external_user if defined?(@current_external_user)

      @current_external_user = (ExternalUser.find_by(id: session[:external_user_id]) if session[:external_user_id])
    end

    def external_user_signed_in?
      current_external_user.present?
    end

    def authenticate_external_user!
      return if external_user_signed_in?

      redirect_to portal_new_external_user_session_path, alert: 'Você precisa fazer login para acessar esta área.'
    end

    private

    def check_external_user_active
      user = current_external_user
      return if user.is_a?(ExternalUser) && user.active?

      sign_out(:external_user) if external_user_signed_in?
      redirect_to portal_new_external_user_session_path,
                  alert: 'Sua conta foi desativada. Entre em contato com o administrador.'
    end
  end
end
