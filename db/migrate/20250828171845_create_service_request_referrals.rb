# frozen_string_literal: true

class CreateServiceRequestReferrals < ActiveRecord::Migration[8.0]
  def change
    create_table :service_request_referrals do |t|
      t.references :service_request, null: false, foreign_key: true
      t.string :cid, null: false
      t.string :encaminhado_para, null: false
      t.string :medico, null: false
      t.text :descricao

      t.timestamps
    end

    add_index :service_request_referrals, :encaminhado_para
  end
end
