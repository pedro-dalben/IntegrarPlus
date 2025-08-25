# frozen_string_literal: true

class CreateDocumentVersions < ActiveRecord::Migration[8.0]
  def change
    create_table :document_versions do |t|
      t.references :document, null: false, foreign_key: true
      t.string :version_number, null: false
      t.string :file_path, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.text :notes

      t.timestamps
    end

    add_index :document_versions, %i[document_id version_number], unique: true
  end
end
