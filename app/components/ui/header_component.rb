# frozen_string_literal: true

class Ui::HeaderComponent < ViewComponent::Base
  def initialize(user: nil)
    @user = user
  end

  private

  attr_reader :user

  def user_name
    user&.full_name || 'Usuário Admin'
  end

  def user_email
    user&.email || 'admin@integrarplus.com'
  end

  def user_avatar
    user&.avatar&.attached? ? user.avatar : nil
  end
end
