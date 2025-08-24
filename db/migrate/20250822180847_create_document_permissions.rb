class CreateDocumentPermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :document_permissions do |t|
      t.references :document, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.references :group, null: true, foreign_key: true
      t.integer :access_level, null: false, default: 0

      t.timestamps
    end

    add_index :document_permissions, :access_level
    add_index :document_permissions, %i[document_id user_id], unique: true, where: 'user_id IS NOT NULL'
    add_index :document_permissions, %i[document_id group_id], unique: true, where: 'group_id IS NOT NULL'

    add_check_constraint :document_permissions, 'user_id IS NOT NULL OR group_id IS NOT NULL',
                         name: 'check_user_or_group_present'
  end
end
