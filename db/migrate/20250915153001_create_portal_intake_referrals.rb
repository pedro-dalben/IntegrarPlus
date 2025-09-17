class CreatePortalIntakeReferrals < ActiveRecord::Migration[8.0]
  def change
    create_table :portal_intake_referrals do |t|
      t.references :portal_intake, null: false, foreign_key: true
      t.string :cid
      t.string :encaminhado_para
      t.string :medico
      t.string :medico_crm
      t.date :data_encaminhamento
      t.text :descricao

      t.timestamps
    end
  end
end
