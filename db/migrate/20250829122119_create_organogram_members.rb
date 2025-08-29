class CreateOrganogramMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :organogram_members do |t|
      t.references :organogram, null: false, foreign_key: true
      t.string :external_id
      t.string :name, null: false
      t.string :role_title
      t.string :department
      t.string :email
      t.string :phone
      t.jsonb :meta, default: {}

      t.timestamps
    end

    add_index :organogram_members, :external_id
    add_index :organogram_members, :name
    add_index :organogram_members, :email
    add_index :organogram_members, [:organogram_id, :external_id], unique: true
  end
end
