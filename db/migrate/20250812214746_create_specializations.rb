# frozen_string_literal: true

class CreateSpecializations < ActiveRecord::Migration[8.0]
  def change
    create_table :specializations do |t|
      t.string :name, null: false
      t.references :speciality, null: false, foreign_key: true

      t.timestamps
    end
    add_index :specializations, :name, unique: true
  end
end
