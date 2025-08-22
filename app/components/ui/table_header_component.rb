# frozen_string_literal: true

module Ui
  class TableHeaderComponent < ViewComponent::Base
    def initialize(text:, classes: nil)
      @text = text
      @classes = classes
    end

    private

    attr_reader :text, :classes

    def header_classes
      base_classes = 'px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500 dark:text-gray-400'
      classes ? "#{base_classes} #{classes}" : base_classes
    end
  end
end
