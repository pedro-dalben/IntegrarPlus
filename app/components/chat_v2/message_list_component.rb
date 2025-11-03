# frozen_string_literal: true

module ChatV2
  class MessageListComponent < ViewComponent::Base
    def initialize(conversation:, current_user:)
      @conversation = conversation
      @current_user = current_user
    end

    def dom_id
      "chat-#{@conversation.identifier}-list"
    end

    def stream_name
      "chat:#{@conversation.identifier}"
    end

    def messages
      start_time = Time.current

      messages_scope = ChatMessage.where(conversation_id: @conversation.id)
                                  .includes(:sender)
                                  .order(:message_number)
                                  .limit(200)

      result = messages_scope.to_a

      duration = ((Time.current - start_time) * 1000).round(2)
      ActiveSupport::Notifications.instrument('render.chat_v2.message_list', {
                                                conversation_id: @conversation.id,
                                                message_count: result.size,
                                                duration_ms: duration
                                              })

      result
    end
  end
end
