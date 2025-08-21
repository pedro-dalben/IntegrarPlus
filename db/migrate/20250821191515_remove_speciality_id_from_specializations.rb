class RemoveSpecialityIdFromSpecializations < ActiveRecord::Migration[8.0]
  def change
    remove_reference :specializations, :speciality, null: false, foreign_key: true
  end
end
