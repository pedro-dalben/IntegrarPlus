# frozen_string_literal: true

module Ui
  class TableCellComponent < ViewComponent::Base
    def initialize(classes: nil)
      @classes = classes
    end

    private

    attr_reader :classes

    def cell_classes
      base_classes = 'whitespace-nowrap px-6 py-4'
      classes ? "#{base_classes} #{classes}" : base_classes
    end
  end
end
