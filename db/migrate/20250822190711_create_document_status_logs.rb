# frozen_string_literal: true

class CreateDocumentStatusLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :document_status_logs do |t|
      t.references :document, null: false, foreign_key: true
      t.integer :old_status
      t.integer :new_status
      t.references :user, null: false, foreign_key: { to_table: :users }
      t.text :notes

      t.timestamps
    end
  end
end
