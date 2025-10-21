# frozen_string_literal: true

class AddEventToMedicalAppointments < ActiveRecord::Migration[8.0]
  def change
    add_reference :medical_appointments, :event, null: true, foreign_key: true
  end
end
