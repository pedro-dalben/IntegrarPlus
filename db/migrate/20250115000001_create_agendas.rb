class CreateAgendas < ActiveRecord::Migration[7.1]
  def change
    create_table :agendas do |t|
      t.string :name, null: false
      t.integer :service_type, null: false, default: 0
      t.integer :default_visibility, null: false, default: 0
      t.references :unit, null: true, foreign_key: false
      t.string :color_theme, default: '#3B82F6'
      t.text :notes
      t.json :working_hours, null: false, default: {}
      t.integer :slot_duration_minutes, null: false, default: 50
      t.integer :buffer_minutes, null: false, default: 10
      t.integer :status, null: false, default: 0
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :updated_by, null: true, foreign_key: { to_table: :users }
      t.integer :lock_version, default: 0

      t.timestamps
    end

    add_index :agendas, %i[name unit_id service_type], unique: true, name: 'index_agendas_unique_name_per_unit_type'
    add_index :agendas, :status
    add_index :agendas, :service_type
  end
end
