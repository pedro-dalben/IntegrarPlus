# frozen_string_literal: true

class Conversation < ApplicationRecord
  belongs_to :context, polymorphic: true, optional: true
  has_many :chat_messages, dependent: :destroy
  has_many :conversation_participations, dependent: :destroy
  has_many :participants, through: :conversation_participations, source: :participant, source_type: 'User'

  enum :conversation_type, {
    group: 0,
    direct: 1,
    channel: 2,
    thread: 3
  }, prefix: :conversation

  enum :status, {
    active: 0,
    archived: 1,
    deleted: 2
  }

  validates :identifier, presence: true, uniqueness: true
  validates :service, presence: true
  validates :context_type, presence: true
  validates :context_id, presence: true
  validates :conversation_type, presence: true
  validates :next_message_number, presence: true, numericality: { greater_than: 0 }
  validates :messages_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :ensure_identifier, on: :create

  scope :for_service, ->(service) { where(service: service) }
  scope :for_context, ->(type, id) { where(context_type: type, context_id: id) }
  scope :active, -> { where(status: :active, deleted_at: nil) }

  def self.generate_identifier(service:, context_type:, context_id:, scope: nil)
    parts = [service, context_type.to_s.underscore, context_id.to_s]
    parts << scope.to_s if scope.present?
    parts.join(':')
  end

  private

  def ensure_identifier
    return if identifier.present?

    self.identifier = self.class.generate_identifier(
      service: service,
      context_type: context_type,
      context_id: context_id,
      scope: scope
    )
  end
end
