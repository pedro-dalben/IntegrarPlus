class CreatePortalIntakes < ActiveRecord::Migration[8.0]
  def change
    create_table :portal_intakes do |t|
      t.references :operator, null: false, foreign_key: { to_table: :external_users }
      t.string :beneficiary_name, null: false
      t.string :plan_name, null: false
      t.string :card_code, null: false
      t.string :status, null: false, default: 'aguardando_agendamento_anamnese'
      t.datetime :requested_at, null: false
      t.date :anamnesis_scheduled_on
      t.timestamps
    end

    add_index :portal_intakes, :status
    add_index :portal_intakes, :requested_at
    add_index :portal_intakes, :anamnesis_scheduled_on
  end
end
