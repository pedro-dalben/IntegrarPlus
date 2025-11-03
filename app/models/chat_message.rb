# frozen_string_literal: true

class ChatMessage < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, polymorphic: true

  enum :content_type, {
    text: 0,
    image: 1,
    file: 2,
    system: 3,
    sticker: 4
  }

  validates :message_number, presence: true, uniqueness: { scope: :conversation_id }
  validates :sender_type, presence: true
  validates :content_type, presence: true
  validates :body, presence: true
  validates :body, length: { maximum: 10_000 }

  scope :for_conversation, ->(conversation_id) { where(conversation_id: conversation_id) }
  scope :active, -> { where(deleted_at: nil) }
  scope :ordered, -> { order(message_number: :asc) }
  scope :recent, -> { order(message_number: :desc) }

  def edited?
    edited_at.present?
  end

  def deleted?
    deleted_at.present?
  end

  after_commit :broadcast_append, on: :create

  private

  def broadcast_append
    return unless AppFlags.chat_v2_enabled?

    rendered = ApplicationController.render(
      ChatV2::MessageComponent.new(message: self, current_user: nil),
      layout: false
    )

    Turbo::StreamsChannel.broadcast_append_to(
      "chat:#{conversation.identifier}",
      target: "chat-#{conversation.identifier}-list",
      html: rendered
    )
  end

  def unique_message_number_per_conversation
    return unless message_number.present? && conversation_id.present?

    existing = ChatMessage.where(
      conversation_id: conversation_id,
      message_number: message_number
    ).where.not(id: id || 0)

    errors.add(:message_number, 'já existe para esta conversa') if existing.exists?
  end
end
