class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.integer :event_type, null: false, default: 0
      t.integer :visibility_level, null: false, default: 0
      t.string :source_context
      t.references :professional, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :professionals }
      t.string :resource_type
      t.integer :status, default: 0

      t.timestamps
    end

    add_index :events, %i[professional_id start_time end_time]
    add_index :events, %i[professional_id event_type]
    add_index :events, %i[professional_id visibility_level]
    add_index :events, %i[start_time end_time]
    add_index :events, :source_context
    add_index :events, :resource_type

    add_check_constraint :events, 'end_time > start_time', name: 'check_end_time_after_start_time'
  end
end
