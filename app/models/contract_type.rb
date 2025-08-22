# frozen_string_literal: true

class ContractType < ApplicationRecord
  include DashboardCache
  include MeiliSearch::Rails

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
  validate :cnpj_requires_company

  has_many :professionals, dependent: :restrict_with_error

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  meilisearch do
    searchable_attributes %i[name description]
    filterable_attributes %i[active created_at updated_at]
    sortable_attributes %i[created_at updated_at name]

    attribute :name
    attribute :description
    attribute :active
    attribute :created_at
    attribute :updated_at
  end

  private

  def cnpj_requires_company
    return unless requires_cnpj? && !requires_company?

    errors.add(:requires_cnpj, 'só pode ser marcado se "Requer Empresa" estiver ativo')
  end
end
