class CreateProfessionalAvailabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :professional_availabilities do |t|
      t.references :professional, null: false, foreign_key: { to_table: :users }
      t.references :agenda, null: true, foreign_key: true
      t.integer :day_of_week, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.boolean :active, default: true
      t.text :notes

      t.timestamps
    end

    add_index :professional_availabilities, %i[professional_id day_of_week]
    add_index :professional_availabilities, :active
  end
end
