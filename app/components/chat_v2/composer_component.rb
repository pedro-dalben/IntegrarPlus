# frozen_string_literal: true

module ChatV2
  class ComposerComponent < ViewComponent::Base
    def initialize(conversation:, current_user:)
      @conversation = conversation
      @current_user = current_user
    end

    def post_path
      if @conversation.context.is_a?(Beneficiary)
        admin_beneficiary_chat_messages_path(@conversation.context, chat_group: @conversation.scope)
      else
        chat_messages_path(@conversation.identifier)
      end
    end

    private

    attr_reader :conversation, :current_user
  end
end
