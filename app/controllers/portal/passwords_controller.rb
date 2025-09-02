# frozen_string_literal: true

module Portal
  class PasswordsController < Devise::PasswordsController
    layout 'auth'

    private

    def after_resetting_password_path_for(_resource)
      portal_root_path
    end
  end
end
