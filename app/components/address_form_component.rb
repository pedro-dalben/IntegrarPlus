# frozen_string_literal: true

class AddressFormComponent < ViewComponent::Base
  def initialize(form:, address_type: 'primary', nested: true, required: false, show_coordinates: false)
    @form = form
    @address_type = address_type
    @nested = nested
    @required = required
    @show_coordinates = show_coordinates
  end

  private

  attr_reader :form, :address_type, :nested, :required, :show_coordinates

  def address_form
    if nested
      # Use nested attributes for the address
      form.fields_for address_association_name, address_object do |address_form|
        yield address_form
      end
    else
      # Direct form for Address model
      yield form
    end
  end

  def address_association_name
    case address_type
    when 'primary'
      :primary_address
    when 'secondary'
      :secondary_address
    else
      :addresses
    end
  end

  def address_object
    case address_type
    when 'primary'
      form.object.primary_address || form.object.build_primary_address(address_type: 'primary')
    when 'secondary'
      form.object.secondary_address || form.object.build_secondary_address(address_type: 'secondary')
    else
      form.object.addresses.build(address_type: address_type)
    end
  end

  def field_name(field)
    nested ? "#{address_association_name}_attributes_#{field}" : field.to_s
  end

  def field_id(field)
    nested ? "#{form.object.class.name.downcase}_#{address_association_name}_attributes_#{field}" : field.to_s
  end

  def required_class
    required ? 'required' : ''
  end

  def input_classes
    "mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white"
  end

  def label_classes
    "block text-sm font-medium text-gray-700 dark:text-gray-300"
  end
end
