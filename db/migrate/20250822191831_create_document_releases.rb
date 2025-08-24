class CreateDocumentReleases < ActiveRecord::Migration[8.0]
  def change
    create_table :document_releases do |t|
      t.references :document, null: false, foreign_key: true
      t.references :version, null: false, foreign_key: { to_table: :document_versions }
      t.references :released_by, null: false, foreign_key: { to_table: :users }
      t.datetime :released_at

      t.timestamps
    end
  end
end
