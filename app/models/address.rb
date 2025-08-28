# frozen_string_literal: true

class Address < ApplicationRecord
  # Polymorphic association - can belong to any model
  belongs_to :addressable, polymorphic: true

  # Validations
  validates :zip_code, presence: true, format: { with: /\A\d{5}-?\d{3}\z/, message: 'must have format 00000-000' }
  validates :street, presence: true
  validates :neighborhood, presence: true
  validates :city, presence: true
  validates :state, presence: true, inclusion: {
    in: %w[AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO],
    message: 'must be a valid Brazilian state'
  }
  validates :address_type, presence: true, inclusion: {
    in: %w[primary secondary billing shipping residential commercial],
    message: 'must be a valid address type'
  }

  # Scopes
  scope :primary, -> { where(address_type: 'primary') }
  scope :secondary, -> { where(address_type: 'secondary') }
  scope :by_type, ->(type) { where(address_type: type) }
  scope :by_state, ->(state) { where(state: state) }
  scope :by_city, ->(city) { where(city: city) }

  # Instance methods
  def full_address
    return '' if [street, neighborhood, city, state].any?(&:blank?)

    parts = []
    parts << street
    parts << neighborhood
    parts << "#{city}/#{state}"
    parts << "ZIP: #{zip_code}" if zip_code.present?

    parts.join(', ')
  end

  def complete?
    [zip_code, street, neighborhood, city, state].all?(&:present?)
  end

  def coordinates_present?
    latitude.present? && longitude.present?
  end

  def to_hash
    {
      zip_code: zip_code,
      street: street,
      neighborhood: neighborhood,
      city: city,
      state: state,
      number: number,
      complement: complement,
      coordinates: {
        latitude: latitude,
        longitude: longitude
      }
    }
  end

  # Class methods
  def self.create_from_cep_data(addressable, cep_data, address_type: 'primary')
    create!(
      addressable: addressable,
      address_type: address_type,
      zip_code: cep_data[:zip_code],
      street: cep_data[:street],
      neighborhood: cep_data[:neighborhood],
      city: cep_data[:city],
      state: cep_data[:state],
      latitude: cep_data.dig(:coordinates, :latitude),
      longitude: cep_data.dig(:coordinates, :longitude)
    )
  end
end
