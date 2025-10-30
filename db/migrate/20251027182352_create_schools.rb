# frozen_string_literal: true

class CreateSchools < ActiveRecord::Migration[8.0]
  def change
    create_table :schools do |t|
      t.string :name, null: false
      t.string :code
      t.string :address
      t.string :neighborhood
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip_code
      t.string :phone
      t.string :email
      t.string :school_type
      t.string :network
      t.boolean :active, default: true, null: false
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end

    add_index :schools, :name
    add_index :schools, :code, unique: true, where: 'code IS NOT NULL'
    add_index :schools, :city
    add_index :schools, :state
    add_index :schools, :active
    add_index :schools, %i[city state]
  end
end
