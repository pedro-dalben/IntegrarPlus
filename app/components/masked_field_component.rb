# frozen_string_literal: true

class MaskedFieldComponent < ViewComponent::Base
  def initialize(form:, field:, type:, label:, placeholder: nil, required: false, **options)
    @form = form
    @field = field
    @type = type
    @label = label
    @placeholder = placeholder || get_default_placeholder
    @required = required
    @options = options
  end

  private

  attr_reader :form, :field, :type, :label, :placeholder, :required, :options

  def get_default_placeholder
    case type
    when 'cpf'
      '000.000.000-00'
    when 'cnpj'
      '00.000.000/0000-00'
    when 'phone'
      '(11) 99999-9999'
    when 'cep'
      '00000-000'
    when 'date'
      'dd/mm/aaaa'
    when 'time'
      'hh:mm'
    else
      ''
    end
  end

  def input_classes
    base_classes = 'block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white dark:placeholder-gray-400'
    base_classes += ' required' if required
    base_classes
  end

  def label_classes
    base_classes = 'block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1'
    base_classes += ' required' if required
    base_classes
  end

  def input_type
    'text_field'
  end

  def data_attributes
    {
      controller: 'masked-input',
      'masked-input-type-value': type,
      'masked-input-placeholder-value': placeholder
    }
  end
end
