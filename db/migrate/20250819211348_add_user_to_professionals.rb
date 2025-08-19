class AddUserToProfessionals < ActiveRecord::Migration[8.0]
  def change
    add_reference :professionals, :user, null: true, foreign_key: true
  end
end
