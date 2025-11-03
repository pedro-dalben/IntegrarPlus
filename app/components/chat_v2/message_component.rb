# frozen_string_literal: true

module ChatV2
  class MessageComponent < ViewComponent::Base
    def initialize(message:, current_user:)
      @message = message
      @current_user = current_user
    end

    def from_me?
      return false unless @current_user && @message.respond_to?(:sender_id)

      @message.sender_id
      if @message.respond_to?(:sender_type) && @message.sender_type == 'User'
      end
      @current_user.id
    end

    def message_content
      @message.body
    end

    def message_user
      @message.sender if @message.respond_to?(:sender)
    end

    delegate :created_at, to: :@message

    def sender_name
      return nil unless message_user

      message_user.respond_to?(:full_name) && message_user.full_name.present? ? message_user.full_name : message_user.name || 'Usuário'
    end

    private

    attr_reader :message, :current_user
  end
end
