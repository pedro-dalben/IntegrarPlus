class CreateMedicalAppointments < ActiveRecord::Migration[8.0]
  def change
    create_table :medical_appointments do |t|
      t.references :agenda, null: false, foreign_key: true
      t.references :professional, null: false, foreign_key: { to_table: :users }
      t.references :patient, null: true, foreign_key: { to_table: :users }
      t.string :appointment_type, null: false
      t.string :status, null: false, default: 'scheduled'
      t.string :priority, null: false, default: 'normal'
      t.datetime :scheduled_at, null: false
      t.integer :duration_minutes, null: false, default: 30
      t.text :notes
      t.string :cancellation_reason
      t.datetime :cancelled_at
      t.string :reschedule_reason
      t.datetime :rescheduled_at
      t.string :no_show_reason
      t.datetime :no_show_at
      t.text :completion_notes
      t.datetime :completed_at

      t.timestamps
    end

    add_index :medical_appointments, :appointment_type
    add_index :medical_appointments, :status
    add_index :medical_appointments, :priority
    add_index :medical_appointments, :scheduled_at
    add_index :medical_appointments, [:professional_id, :scheduled_at]
    add_index :medical_appointments, [:patient_id, :scheduled_at]
  end
end
