class CreateAppointmentAttachments < ActiveRecord::Migration[8.0]
  def change
    create_table :appointment_attachments do |t|
      t.references :medical_appointment, null: false, foreign_key: true
      t.references :uploaded_by, null: false, foreign_key: { to_table: :users }
      t.string :attachment_type, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :appointment_attachments, :attachment_type
    add_index :appointment_attachments, [:medical_appointment_id, :created_at]
  end
end
