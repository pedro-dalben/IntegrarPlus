# frozen_string_literal: true

module Ui
  class HeaderComponent < ViewComponent::Base
    def initialize(current_user: nil)
      @current_user = current_user
    end

    private

    attr_reader :current_user

    def user_name
      current_user&.name || 'Usuário'
    end

    def user_email
      current_user&.email || 'usuario@example.com'
    end

    def user_avatar
      current_user&.avatar || 'user/user-01.jpg'
    end
  end
end
