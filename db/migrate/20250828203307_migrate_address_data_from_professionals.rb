class MigrateAddressDataFromProfessionals < ActiveRecord::Migration[8.0]
  def up
    # First, ensure addresses table exists
    return unless table_exists?(:addresses)

    # Migrate existing address data from professionals to addresses table
    Professional.find_each do |professional|
      # Only migrate if professional has address data
      if professional.zip_code.present? || professional.street.present?
        Address.create!(
          addressable: professional,
          address_type: 'primary',
          zip_code: professional.zip_code || '',
          street: professional.street || '',
          number: professional.number || '',
          complement: professional.complement || '',
          neighborhood: professional.neighborhood || '',
          city: professional.city || '',
          state: professional.state || '',
          latitude: professional.latitude,
          longitude: professional.longitude
        )
      end
    rescue => e
      Rails.logger.error "Failed to migrate address for Professional #{professional.id}: #{e.message}"
    end

    # Remove old address columns from professionals table
    remove_columns_if_exist(:professionals,
      :zip_code, :street, :number, :complement,
      :neighborhood, :city, :state, :latitude, :longitude
    )

    # Remove old indexes
    remove_index_if_exists(:professionals, :zip_code)
    remove_index_if_exists(:professionals, :city)
    remove_index_if_exists(:professionals, :state)
  end

  def down
    # Add back the old columns
    add_column :professionals, :zip_code, :string
    add_column :professionals, :street, :string
    add_column :professionals, :number, :string
    add_column :professionals, :complement, :string
    add_column :professionals, :neighborhood, :string
    add_column :professionals, :city, :string
    add_column :professionals, :state, :string
    add_column :professionals, :latitude, :decimal, precision: 10, scale: 8
    add_column :professionals, :longitude, :decimal, precision: 11, scale: 8

    # Migrate data back from addresses to professionals
    Professional.includes(:primary_address).find_each do |professional|
      if professional.primary_address
        address = professional.primary_address
        professional.update_columns(
          zip_code: address.zip_code,
          street: address.street,
          number: address.number,
          complement: address.complement,
          neighborhood: address.neighborhood,
          city: address.city,
          state: address.state,
          latitude: address.latitude,
          longitude: address.longitude
        )
      end
    end

    # Add back indexes
    add_index :professionals, :zip_code
    add_index :professionals, :city
    add_index :professionals, :state
  end

  private

  def remove_columns_if_exist(table, *columns)
    columns.each do |column|
      remove_column table, column if column_exists?(table, column)
    end
  end

  def remove_index_if_exists(table, column)
    remove_index table, column if index_exists?(table, column)
  end
end
