# frozen_string_literal: true

class DateFieldComponent < ViewComponent::Base
  def initialize(form:, field:, label:, required: false, **options)
    @form = form
    @field = field
    @label = label
    @required = required
    @options = options
  end

  private

  attr_reader :form, :field, :label, :required, :options

  def input_classes
    base_classes = 'block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white'
    base_classes += ' required' if required
    base_classes
  end

  def label_classes
    base_classes = 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1'
    base_classes += ' required' if required
    base_classes
  end

  def data_attributes
    {
      controller: 'masked-input',
      'masked-input-type-value': 'date'
    }
  end
end
