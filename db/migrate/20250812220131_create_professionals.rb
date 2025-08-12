class CreateProfessionals < ActiveRecord::Migration[8.0]
  def change
    create_table :professionals do |t|
      t.string :full_name, null: false
      t.date :birth_date
      t.string :cpf, null: false
      t.string :phone
      t.string :email, null: false
      t.boolean :active, default: true, null: false
      t.references :contract_type, null: true, foreign_key: true
      t.date :hired_on
      t.integer :workload_minutes, default: 0, null: false
      t.string :council_code
      t.string :company_name
      t.string :cnpj

      t.timestamps
    end
    add_index :professionals, :cpf, unique: true
    add_index :professionals, :email, unique: true
  end
end
