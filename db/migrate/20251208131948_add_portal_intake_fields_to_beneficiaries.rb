# frozen_string_literal: true

class AddPortalIntakeFieldsToBeneficiaries < ActiveRecord::Migration[8.0]
  def change
    add_column :beneficiaries, :card_code, :string
    add_column :beneficiaries, :plan_name, :string
    add_column :beneficiaries, :tipo_convenio, :string
    add_column :beneficiaries, :data_encaminhamento, :date
    add_column :beneficiaries, :data_recebimento_email, :date
    add_reference :beneficiaries, :external_user, null: true, foreign_key: true
    
    add_index :beneficiaries, :data_encaminhamento
    add_index :beneficiaries, :data_recebimento_email
  end
end
