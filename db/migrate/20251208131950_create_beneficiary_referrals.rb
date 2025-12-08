# frozen_string_literal: true

class CreateBeneficiaryReferrals < ActiveRecord::Migration[8.0]
  def change
    create_table :beneficiary_referrals do |t|
      t.references :beneficiary, null: false, foreign_key: true
      t.string :cid, limit: 20
      t.string :encaminhado_para
      t.string :medico, limit: 100
      t.string :medico_crm, limit: 20
      t.date :data_encaminhamento
      t.text :descricao

      t.timestamps
    end

    add_index :beneficiary_referrals, :encaminhado_para
  end
end
