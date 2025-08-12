class CreateProfessionalSpecialities < ActiveRecord::Migration[8.0]
  def change
    create_table :professional_specialities do |t|
      t.references :professional, null: false, foreign_key: true
      t.references :speciality, null: false, foreign_key: true

      t.timestamps
    end
    add_index :professional_specialities, [:professional_id, :speciality_id], unique: true, name: 'index_professional_specialities_unique'
  end
end
