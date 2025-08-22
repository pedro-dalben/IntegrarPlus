# frozen_string_literal: true

module Ui
  class TableRowComponent < ViewComponent::Base
    renders_many :cells

    def initialize(model:, classes: nil)
      @model = model
      @classes = classes
    end

    private

    attr_reader :model, :classes

    def row_classes
      base_classes = 'hover:bg-gray-50 dark:hover:bg-gray-900'
      classes ? "#{base_classes} #{classes}" : base_classes
    end

    def cell_classes
      'whitespace-nowrap px-6 py-4'
    end
  end
end
