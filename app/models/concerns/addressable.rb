# frozen_string_literal: true

module Addressable
  extend ActiveSupport::Concern

  included do
    has_many :addresses, as: :addressable, dependent: :destroy
    has_one :primary_address, -> { where(address_type: 'primary') },
            as: :addressable, class_name: 'Address'
    has_one :secondary_address, -> { where(address_type: 'secondary') },
            as: :addressable, class_name: 'Address'

    # Nested attributes for easy form handling
    accepts_nested_attributes_for :addresses, allow_destroy: true
    accepts_nested_attributes_for :primary_address, allow_destroy: true
  end

  # Instance methods
  def address_by_type(type)
    addresses.find_by(address_type: type)
  end

  def has_address?(type = 'primary')
    address_by_type(type).present?
  end

  def full_address(type = 'primary')
    address = address_by_type(type)
    address&.full_address || ''
  end

  def complete_address?(type = 'primary')
    address = address_by_type(type)
    address&.complete? || false
  end

  # Create address from CEP service data
  def create_address_from_cep(cep_data, type: 'primary', **additional_fields)
    address_data = cep_data.merge(additional_fields)

    existing_address = address_by_type(type)
    if existing_address
      existing_address.update!(address_data.except(:coordinates).merge(
                                 latitude: cep_data.dig(:coordinates, :latitude),
                                 longitude: cep_data.dig(:coordinates, :longitude)
                               ))
      existing_address
    else
      Address.create_from_cep_data(self, cep_data, address_type: type)
    end
  end

  # Delegate common address methods to primary address
  def zip_code
    primary_address&.zip_code
  end

  def street
    primary_address&.street
  end

  def neighborhood
    primary_address&.neighborhood
  end

  def city
    primary_address&.city
  end

  def state
    primary_address&.state
  end

  def coordinates
    return nil unless primary_address&.coordinates_present?

    {
      latitude: primary_address.latitude,
      longitude: primary_address.longitude
    }
  end

  # Legacy compatibility methods
  def endereco_completo
    full_address
  end

  def endereco_completo?
    complete_address?
  end
end
