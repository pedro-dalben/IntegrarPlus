# frozen_string_literal: true

module ChatV2
  class MarkRead
    def self.call(conversation:, participant:, message_number: nil)
      new(conversation: conversation, participant: participant, message_number: message_number).call
    end

    def initialize(conversation:, participant:, message_number: nil)
      @conversation = conversation.is_a?(Conversation) ? conversation : Conversation.find(conversation)
      @participant = participant
      @message_number = message_number
    end

    def call
      ConversationParticipation.transaction do
        participation = ConversationParticipation.find_or_initialize_by(
          conversation: @conversation,
          participant: @participant,
          left_at: nil
        )

        if participation.new_record?
          participation.assign_attributes(
            role: :member,
            notifications_enabled: true,
            notification_preferences: {},
            joined_at: Time.current
          )
        end

        target_message_number = @message_number || @conversation.messages_count

        if target_message_number > participation.last_read_message_number
          participation.update!(
            last_read_message_number: target_message_number,
            unread_count: [0, @conversation.messages_count - target_message_number].max
          )
        end

        participation
      end
    end
  end
end
