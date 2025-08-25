# frozen_string_literal: true

class CreateDocumentTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :document_tasks do |t|
      t.references :document, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :priority
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :assigned_to, null: true, foreign_key: { to_table: :users }
      t.references :completed_by, null: true, foreign_key: { to_table: :users }
      t.datetime :completed_at

      t.timestamps
    end
  end
end
