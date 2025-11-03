# frozen_string_literal: true

module ChatV2
  class ConversationComponent < ViewComponent::Base
    def initialize(conversation:, current_user:)
      @conversation = conversation
      @current_user = current_user
    end

    private

    attr_reader :conversation, :current_user

    def messages_scope
      ChatMessage.where(conversation_id: conversation.id)
    end
  end
end
