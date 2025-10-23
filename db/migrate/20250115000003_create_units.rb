# frozen_string_literal: true

class CreateUnits < ActiveRecord::Migration[7.1]
  def change
    create_table :units do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :units, :name, unique: true
    add_index :units, :active
  end
end
