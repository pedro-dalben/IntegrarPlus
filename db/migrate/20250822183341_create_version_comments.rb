class CreateVersionComments < ActiveRecord::Migration[8.0]
  def change
    create_table :version_comments do |t|
      t.references :document_version, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :comment_text, null: false

      t.timestamps
    end

    add_index :version_comments, :created_at
  end
end
