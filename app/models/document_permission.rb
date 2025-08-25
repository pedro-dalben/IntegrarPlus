# frozen_string_literal: true

class DocumentPermission < ApplicationRecord
  belongs_to :document
  belongs_to :user, optional: true
  belongs_to :group, optional: true

  enum :access_level, {
    visualizar: 0,
    comentar: 1,
    editar: 2
  }

  validates :access_level, presence: true
  validates :user_id, uniqueness: { scope: :document_id }, allow_nil: true
  validates :group_id, uniqueness: { scope: :document_id }, allow_nil: true
  validate :user_or_group_present

  scope :for_user, ->(user) { where(user: user) }
  scope :for_group, ->(group) { where(group: group) }
  scope :for_user_and_groups, lambda { |user|
    where(user: user).or(where(group: user.groups))
  }

  def grantee_name
    user&.full_name || group&.name
  end

  def grantee_type
    user_id.present? ? 'user' : 'group'
  end

  private

  def user_or_group_present
    errors.add(:base, 'Deve especificar um usuário ou grupo') if user_id.blank? && group_id.blank?

    return unless user_id.present? && group_id.present?

    errors.add(:base, 'Não pode especificar usuário e grupo simultaneamente')
  end
end
