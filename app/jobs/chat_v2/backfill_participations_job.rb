# frozen_string_literal: true

module ChatV2
  class BackfillParticipationsJob < ApplicationJob
    queue_as :default

    def perform(conversation_id)
      conversation = Conversation.find(conversation_id)
      return unless conversation

      context = conversation.context
      return unless context.is_a?(Beneficiary)

      context.professionals.includes(:user).find_each do |professional|
        next unless professional.user

        ConversationParticipation.find_or_create_by!(
          conversation: conversation,
          participant: professional.user,
          participant_type: 'User',
          left_at: nil
        ) do |participation|
          participation.role = :member
          participation.last_read_message_number = 0
          participation.unread_count = conversation.messages_count
          participation.notifications_enabled = true
          participation.notification_preferences = {}
          participation.joined_at = conversation.created_at || Time.current
        end
      end
    end
  end
end
