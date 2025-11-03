# frozen_string_literal: true

module ChatV2
  class SendMessage
    def self.call(conversation:, sender:, body:, content_type: :text, metadata: {})
      new(conversation: conversation, sender: sender, body: body, content_type: content_type, metadata: metadata).call
    end

    def initialize(conversation:, sender:, body:, content_type: :text, metadata: {})
      @conversation = conversation.is_a?(Conversation) ? conversation : Conversation.find(conversation)
      @sender = sender
      @body = body
      @content_type = content_type
      @metadata = metadata
    end

    def call
      Conversation.transaction do
        conversation = Conversation.lock.find(@conversation.id)

        sql = ActiveRecord::Base.sanitize_sql_array([
                                                      'UPDATE conversations SET next_message_number = next_message_number + 1 WHERE id = ? RETURNING next_message_number',
                                                      conversation.id
                                                    ])
        result = ActiveRecord::Base.connection.execute(sql)
        message_number = result.first['next_message_number'].to_i

        message = ChatMessage.create!(
          conversation: conversation,
          message_number: message_number,
          sender: @sender,
          body: @body,
          content_type: @content_type,
          metadata: @metadata
        )

        conversation.reload
        conversation.update!(
          messages_count: conversation.messages_count + 1,
          last_message_id: message.id,
          last_message_at: message.created_at
        )

        message
      end
    end
  end
end
