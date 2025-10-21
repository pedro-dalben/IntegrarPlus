# frozen_string_literal: true

class FixForeignKeysToProfessionals < ActiveRecord::Migration[8.0]
  def change
    # Remove foreign keys that point to users table
    remove_foreign_key :professional_availabilities, :users, column: :professional_id
    remove_foreign_key :availability_exceptions, :users, column: :professional_id
    remove_foreign_key :medical_appointments, :users, column: :professional_id
    # remove_foreign_key :events, :users, column: :created_by_id # Esta FK não existe

    # Add foreign keys that point to professionals table
    add_foreign_key :professional_availabilities, :professionals, column: :professional_id
    add_foreign_key :availability_exceptions, :professionals, column: :professional_id
    add_foreign_key :medical_appointments, :professionals, column: :professional_id
    # add_foreign_key :events, :professionals, column: :created_by_id # Já existe
  end
end
