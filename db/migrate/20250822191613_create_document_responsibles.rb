# frozen_string_literal: true

class CreateDocumentResponsibles < ActiveRecord::Migration[8.0]
  def change
    create_table :document_responsibles do |t|
      t.references :document, null: false, foreign_key: true
      t.integer :status
      t.references :user, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
