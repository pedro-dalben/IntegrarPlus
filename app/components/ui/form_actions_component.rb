# frozen_string_literal: true

module Ui
  class FormActionsComponent < ViewComponent::Base
    renders_one :cancel_button
    renders_one :submit_button

    def initialize(cancel_path:, submit_text:)
      @cancel_path = cancel_path
      @submit_text = submit_text
    end

    private

    attr_reader :cancel_path, :submit_text
  end
end
