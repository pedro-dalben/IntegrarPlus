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
end
