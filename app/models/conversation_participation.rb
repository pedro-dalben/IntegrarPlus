# frozen_string_literal: true

class ConversationParticipation < ApplicationRecord
  belongs_to :conversation
  belongs_to :participant, polymorphic: true

  enum :role, {
    owner: 0,
    admin: 1,
    member: 2,
    viewer: 3
  }

  validates :participant_type, presence: true
  validates :role, presence: true
  validates :last_read_message_number, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unread_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :notifications_enabled, inclusion: { in: [true, false] }

  validate :unique_active_participation

  def unique_active_participation
    return unless left_at.nil?

    existing = ConversationParticipation.where(
      conversation_id: conversation_id,
      participant_type: participant_type,
      participant_id: participant_id,
      left_at: nil
    ).where.not(id: id || 0)

    errors.add(:participant_id, 'já está participando desta conversa') if existing.exists?
  end

  scope :active, -> { where(left_at: nil) }
  scope :for_participant, ->(type, id) { where(participant_type: type, participant_id: id) }
end
