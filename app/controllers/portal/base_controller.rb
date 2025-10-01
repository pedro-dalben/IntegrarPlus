# frozen_string_literal: true

module Portal
  class BaseController < ApplicationController
    layout 'portal'

    before_action :enforce_external_user_timeout, if: -> { Rails.env.production? }
    before_action :authenticate_external_user!
    before_action :check_external_user_active

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

      # Limpar a sessão do usuário inativo
      session[:external_user_id] = nil
      redirect_to portal_new_external_user_session_path,
                  alert: 'Sua conta foi desativada. Entre em contato com o administrador do sistema para reativar seu acesso.'
    end

    def enforce_external_user_timeout
      return unless session[:external_user_id]

      last_seen_at = session[:external_user_last_seen_at]
      last_seen_at = Time.zone.parse(last_seen_at) if last_seen_at.is_a?(String)
      last_seen_at = Time.zone.at(last_seen_at) if last_seen_at.is_a?(Numeric)
      last_seen_at = last_seen_at.in_time_zone if last_seen_at.respond_to?(:in_time_zone)

      if last_seen_at.present? && last_seen_at < 60.minutes.ago
        session[:external_user_id] = nil
        session[:external_user_last_seen_at] = nil
        redirect_to portal_new_external_user_session_path,
                    alert: 'Sua sessão foi encerrada por inatividade.' and return
      end

      session[:external_user_last_seen_at] = Time.current.iso8601
    end
  end
end
