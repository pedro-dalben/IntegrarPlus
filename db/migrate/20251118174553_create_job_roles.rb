class CreateJobRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :job_roles do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :job_roles, :name, unique: true
    add_index :job_roles, :active
  end
end

