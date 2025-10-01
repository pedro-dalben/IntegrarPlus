class ChangeAnamnesisToOptionalInMedicalAppointments < ActiveRecord::Migration[8.0]
  def change
    change_column_null :medical_appointments, :anamnesis_id, true
  end
end
