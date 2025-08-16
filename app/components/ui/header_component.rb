# frozen_string_literal: true

class Ui::HeaderComponent < ViewComponent::Base
  def initialize(user: nil)
    @user = user
  end

  private

  attr_reader :user

  def user_name
    user&.name || "Usuário Admin"
  end
end