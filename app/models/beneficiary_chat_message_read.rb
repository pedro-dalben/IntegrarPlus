# frozen_string_literal: true

class BeneficiaryChatMessageRead < ApplicationRecord
  belongs_to :beneficiary_chat_message
  belongs_to :user

  validates :read_at, presence: true

  before_validation :set_read_at, on: :create

  after_create_commit :broadcast_read_status

  private

  def set_read_at
    self.read_at ||= Time.current
  end

  def broadcast_read_status
    # O broadcast será feito via JavaScript após a marcação de leitura
    # Não podemos fazer broadcast da partial aqui porque cada aba tem um current_user diferente
    # O status será atualizado via Turbo Stream response do controller
  end
end
