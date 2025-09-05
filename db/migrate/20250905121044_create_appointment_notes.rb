class CreateAppointmentNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :appointment_notes do |t|
      t.references :medical_appointment, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string :note_type, null: false
      t.text :content, null: false

      t.timestamps
    end

    add_index :appointment_notes, :note_type
    add_index :appointment_notes, [:medical_appointment_id, :created_at]
  end
end
