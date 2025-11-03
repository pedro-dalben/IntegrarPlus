# frozen_string_literal: true

module Chat
  class SendMessage
    def self.call(conversation:, sender:, body:, content_type: :text, metadata: {})
      new(conversation: conversation, sender: sender, body: body, content_type: content_type, metadata: metadata).call
    end

    def initialize(conversation:, sender:, body:, content_type: :text, metadata: {})
      @conversation = conversation
      @sender = sender
      @body = body
      @content_type = content_type
      @metadata = metadata
    end

    def call
      ChatV2::SendMessage.call(
        conversation: @conversation,
        sender: @sender,
        body: @body,
        content_type: @content_type,
        metadata: @metadata
      )
    end
  end
end
