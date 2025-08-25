class CreateProfessionalGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :professional_groups do |t|
      t.references :professional, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end

    add_index :professional_groups, [:professional_id, :group_id], unique: true
  end
end
