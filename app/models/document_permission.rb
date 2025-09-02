# frozen_string_literal: true

class DocumentPermission < ApplicationRecord
  belongs_to :document
  belongs_to :professional, optional: true
  belongs_to :group, optional: true

  enum :access_level, {
    visualizar: 0,
    comentar: 1,
    editar: 2
  }

  validates :access_level, presence: true
  validates :professional_id, uniqueness: { scope: :document_id }, allow_nil: true
  validates :group_id, uniqueness: { scope: :document_id }, allow_nil: true
  validate :professional_or_group_present

  scope :for_professional, ->(professional) { where(professional: professional) }
  scope :for_group, ->(group) { where(group: group) }
  scope :for_professional_and_groups, lambda { |professional|
    return none if professional.blank?

    where(professional: professional).or(where(group: professional.groups))
  }

  # Métodos de compatibilidade com User (deprecated)
  scope :for_user, ->(user) { for_professional(user&.professional) }
  scope :for_user_and_groups, lambda { |user|
    for_professional_and_groups(user&.professional)
  }

  def grantee_name
    professional&.full_name || group&.name
  end

  def grantee_type
    professional_id.present? ? 'professional' : 'group'
  end

  # Método de compatibilidade (deprecated)
  def user
    professional&.user
  end

  def user_id
    professional&.user_id
  end

  private

  def professional_or_group_present
    errors.add(:base, 'Deve especificar um profissional ou grupo') if professional_id.blank? && group_id.blank?

    return unless professional_id.present? && group_id.present?

    errors.add(:base, 'Não pode especificar profissional e grupo simultaneamente')
  end
end
