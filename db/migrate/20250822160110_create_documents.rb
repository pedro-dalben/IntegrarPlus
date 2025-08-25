# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.string :title, null: false, limit: 150
      t.text :description
      t.integer :document_type, null: false, default: 0
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0
      t.string :current_version, null: false, default: '1.0'

      t.timestamps
    end

    add_index :documents, :document_type
    add_index :documents, :status
  end
end
