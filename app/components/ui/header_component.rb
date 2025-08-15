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
      if current_user&.avatar.present?
        current_user.avatar
      else
        'fakeperson.webp'
      end
    end
  end
end
