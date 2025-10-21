# frozen_string_literal: true

class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  # CSRF protection
  protect_from_forgery with: :exception

  include Admin::SidebarHelper
  include Pundit::Authorization
  include Pagy::Backend
  include PagyMeilisearchHelper

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit
  before_action :enforce_user_timeout, if: -> { user_signed_in? }

  helper_method :current_professional

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])

    # Para ExternalUsers
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name company_name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name company_name])
  end

  def current_professional
    @current_professional ||= current_user&.professional
  end

  def pundit_user
    if respond_to?(:current_external_user) && current_external_user
      current_external_user
    else
      current_user
    end
  end

  def after_sign_in_path_for(_resource)
    admin_root_path
  end

  private

  def enforce_user_timeout
    return unless session[:user_id]

    last_seen_at = session[:user_last_seen_at]
    last_seen_at = Time.zone.parse(last_seen_at) if last_seen_at.is_a?(String)
    last_seen_at = Time.zone.at(last_seen_at) if last_seen_at.is_a?(Numeric)
    last_seen_at = last_seen_at.in_time_zone if last_seen_at.respond_to?(:in_time_zone)

    timeout_minutes = Rails.env.production? ? 60 : 60
    if last_seen_at.present? && last_seen_at < timeout_minutes.minutes.ago
      session[:user_id] = nil
      session[:user_last_seen_at] = nil
      redirect_to new_user_session_path,
                  alert: 'Sua sessão foi encerrada por inatividade.' and return
    end

    session[:user_last_seen_at] = Time.current.iso8601
  end
end
