# frozen_string_literal: true

class AddAnamnesisToMedicalAppointments < ActiveRecord::Migration[8.0]
  def change
    add_reference :medical_appointments, :anamnesis, null: true, foreign_key: true
  end
end
