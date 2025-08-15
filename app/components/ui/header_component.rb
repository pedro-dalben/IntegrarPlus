# frozen_string_literal: true

class Ui::HeaderComponent < ViewComponent::Base
  def initialize(user: nil, **options)
    @user = user
    @options = options
  end

  private

  attr_reader :user, :options

  def user_name
    user&.name || "Usuário"
  end

  def user_email
    user&.email || "usuario@integrarplus.com"
  end

  def user_avatar
    user&.avatar&.attached? ? user.avatar : nil
  end

  def notifications_count
    # Implementar lógica de notificações
    3
  end

  def messages_count
    # Implementar lógica de mensagens
    2
  end
end