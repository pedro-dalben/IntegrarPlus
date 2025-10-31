# frozen_string_literal: true

class CreateBeneficiaryProfessionals < ActiveRecord::Migration[8.0]
  def change
    create_table :beneficiary_professionals do |t|
      t.references :beneficiary, null: false, foreign_key: true
      t.references :professional, null: false, foreign_key: true

      t.timestamps
    end

    add_index :beneficiary_professionals, %i[beneficiary_id professional_id], unique: true,
                                                                              name: 'index_beneficiary_professionals_unique'
  end
end
