# frozen_string_literal: true

module ChatV2
  class TypingIndicatorComponent < ViewComponent::Base
    def initialize(conversation:)
      @conversation = conversation
    end

    private

    attr_reader :conversation
  end
end
