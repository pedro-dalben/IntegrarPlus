# frozen_string_literal: true

class BeneficiaryChatMessage < ApplicationRecord
  belongs_to :beneficiary
  belongs_to :user
  has_many :beneficiary_chat_message_reads, dependent: :destroy
  has_many :readers, through: :beneficiary_chat_message_reads, source: :user

  enum :chat_group, {
    professionals_only: 'professionals_only',
    general: 'general'
  }

  validates :content, presence: true, length: { maximum: 5000 }
  validates :chat_group, presence: true

  scope :unread_by, lambda { |user|
    where.not(id: joins(:beneficiary_chat_message_reads).where(beneficiary_chat_message_reads: { user_id: user.id }).select(:id))
  }
  scope :read_by, lambda { |user|
    joins(:beneficiary_chat_message_reads).where(beneficiary_chat_message_reads: { user_id: user.id })
  }
  scope :for_group, ->(group) { where(chat_group: group) }

  def read_by?(user)
    beneficiary_chat_message_reads.exists?(user_id: user.id)
  end

  def mark_as_read_by(user)
    return if read_by?(user)

    beneficiary_chat_message_reads.create!(user: user, read_at: Time.current)
  end

  after_create_commit do
    broadcast_append_to(
      "beneficiary_chat_#{beneficiary_id}_#{chat_group}",
      target: "beneficiary_chat_messages_#{beneficiary_id}_#{chat_group}",
      partial: 'admin/beneficiaries/tabs/chat_message',
      locals: { message: self }
    )
    NotificationService.send_chat_message_notification(self)
  end
end
