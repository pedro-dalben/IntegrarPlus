class CreateProfessionalSpecializations < ActiveRecord::Migration[8.0]
  def change
    create_table :professional_specializations do |t|
      t.references :professional, null: false, foreign_key: true
      t.references :specialization, null: false, foreign_key: true

      t.timestamps
    end
    add_index :professional_specializations, [:professional_id, :specialization_id], unique: true, name: 'index_professional_specializations_unique'
  end
end
