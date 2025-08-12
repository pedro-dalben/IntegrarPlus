class ContractType < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validate :cnpj_requires_company

  scope :ordered, -> { order(:name) }

  private

  def cnpj_requires_company
    return unless requires_cnpj? && !requires_company?

    errors.add(:requires_cnpj, 'só pode ser marcado se "Requer Empresa" estiver ativo')
  end
end
