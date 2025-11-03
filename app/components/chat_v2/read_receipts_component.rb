# frozen_string_literal: true

module ChatV2
  class ReadReceiptsComponent < ViewComponent::Base
    def initialize(message:)
      @message = message
    end

    def readers
      return [] unless @message.respond_to?(:readers)

      @message.readers.where.not(id: @message.user_id || @message.sender_id)
    end

    def read_count
      readers.count
    end

    private

    attr_reader :message
  end
end
