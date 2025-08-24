class VersionComment < ApplicationRecord
  belongs_to :document_version
  belongs_to :user

  validates :comment_text, presence: true, length: { minimum: 1, maximum: 1000 }

  scope :ordered, -> { order(created_at: :asc) }

  delegate :document, to: :document_version

  def can_be_edited_by?(user)
    user == self.user || document.user_can_edit?(user)
  end

  def can_be_deleted_by?(user)
    user == self.user || document.user_can_edit?(user)
  end
end
