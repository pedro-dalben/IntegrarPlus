class CreateAvailabilityExceptions < ActiveRecord::Migration[8.0]
  def change
    create_table :availability_exceptions do |t|
      t.references :professional, null: false, foreign_key: { to_table: :users }
      t.references :agenda, null: true, foreign_key: true
      t.date :exception_date, null: false
      t.integer :exception_type, null: false
      t.time :start_time
      t.time :end_time
      t.text :reason
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :availability_exceptions, %i[professional_id exception_date]
    add_index :availability_exceptions, :exception_type
  end
end
