# frozen_string_literal: true

class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  # CSRF protection
  protect_from_forgery with: :exception

  include Admin::SidebarHelper
  include Pundit::Authorization
  include Pagy::Backend

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
