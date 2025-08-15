# frozen_string_literal: true
class Ui::HeaderComponentPreview < ViewComponent::Preview
  def default
    render Ui::HeaderComponent.new
  end

  def with_user
    user = OpenStruct.new(
      name: "João Silva",
      email: "joao.silva@example.com",
      avatar: "app/assets/images/user/user-01.jpg"
    )
    render Ui::HeaderComponent.new(current_user: user)
  end
end
