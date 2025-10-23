# frozen_string_literal: true

class CreateNews < ActiveRecord::Migration[8.0]
  def change
    create_table :news do |t|
      t.string :title
      t.text :content
      t.boolean :published
      t.datetime :published_at
      t.string :author

      t.timestamps
    end
  end
end
