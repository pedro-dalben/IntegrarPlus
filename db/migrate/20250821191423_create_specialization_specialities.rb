class CreateSpecializationSpecialities < ActiveRecord::Migration[8.0]
  def change
    create_table :specialization_specialities do |t|
      t.references :specialization, null: false, foreign_key: true
      t.references :speciality, null: false, foreign_key: true
      t.timestamps
    end

    add_index :specialization_specialities, %i[specialization_id speciality_id], unique: true,
                                                                                 name: 'index_spec_spec_on_spec_id_and_spec_id'
  end
end
