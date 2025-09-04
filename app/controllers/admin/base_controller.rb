# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    layout 'admin'

    before_action :authenticate_user!
    before_action :check_permissions

    helper_method :admin_nav
    include EventsHelper

    private

    def admin_nav
      AdminNav.items.select { |item| current_user.permit?(item[:required_permission]) }
    end

    def check_permissions
      action_permission = "#{controller_name}.#{action_name}"

      # Dashboard é acessível para todos os usuários autenticados
      return if controller_name == 'dashboard' && action_name == 'index'

      return if current_user.permit?(action_permission)

      redirect_to admin_path, alert: 'Você não tem permissão para acessar esta área.'
    end

    def require_permission(permission_key)
      return if current_user.permit?(permission_key)

      redirect_to admin_path, alert: 'Você não tem permissão para realizar esta ação.'
    end
  end
end
