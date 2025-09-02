# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.references :addressable, polymorphic: true, null: false
      t.string :address_type, null: false, default: 'primary'
      t.string :zip_code, null: false
      t.string :street, null: false
      t.string :number
      t.string :complement
      t.string :neighborhood, null: false
      t.string :city, null: false
      t.string :state, null: false, limit: 2
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8

      t.timestamps
    end

    # Indexes for better performance
    add_index :addresses, %i[addressable_type addressable_id]
    add_index :addresses, %i[addressable_type addressable_id address_type],
              name: 'index_addresses_on_addressable_and_type'
    add_index :addresses, :zip_code
    add_index :addresses, :city
    add_index :addresses, :state
    add_index :addresses, %i[latitude longitude], name: 'index_addresses_on_coordinates'
  end
end
