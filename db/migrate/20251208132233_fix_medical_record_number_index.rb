# frozen_string_literal: true

class FixMedicalRecordNumberIndex < ActiveRecord::Migration[8.0]
  def up
    remove_index :beneficiaries, :medical_record_number, if_exists: true
    
    execute <<-SQL
      UPDATE beneficiaries 
      SET medical_record_number = NULL 
      WHERE medical_record_number = '' OR medical_record_number IS NULL OR TRIM(medical_record_number) = '';
    SQL
    
    add_index :beneficiaries, :medical_record_number, 
              unique: true, 
              where: "medical_record_number IS NOT NULL",
              name: "index_beneficiaries_on_medical_record_number"
  end

  def down
    remove_index :beneficiaries, name: "index_beneficiaries_on_medical_record_number", if_exists: true
    add_index :beneficiaries, :medical_record_number, unique: true
  end
end
