class CreateAgendaProfessionals < ActiveRecord::Migration[7.1]
  def change
    create_table :agenda_professionals do |t|
      t.references :agenda, null: false, foreign_key: true
      t.references :professional, null: false, foreign_key: { to_table: :users }
      t.integer :capacity_per_slot, default: 1
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :agenda_professionals, %i[agenda_id professional_id], unique: true
    add_index :agenda_professionals, :professional_id, name: 'index_agenda_professionals_on_professional_id_unique'
    add_index :agenda_professionals, :active
  end
end
