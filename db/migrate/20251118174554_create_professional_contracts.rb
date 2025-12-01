class CreateProfessionalContracts < ActiveRecord::Migration[8.0]
  def change
    create_table :professional_contracts do |t|
      t.references :professional, null: false, foreign_key: true, index: { unique: true }
      t.string :contract_type_enum
      t.string :nationality
      t.text :professional_formation
      t.string :rg
      t.string :cpf
      t.string :council_registration_number
      t.references :job_role, null: true, foreign_key: true
      t.string :payment_type
      t.decimal :monthly_value, precision: 10, scale: 2
      t.decimal :hourly_value, precision: 10, scale: 2
      t.decimal :overtime_hour_value, precision: 10, scale: 2, default: 17.00

      t.string :company_cnpj
      t.text :company_address
      t.string :company_represented_by

      t.string :ccm
      t.text :taxpayer_address

      t.string :contract_pdf_path
      t.string :anexo_pdf_path
      t.string :termo_pdf_path

      t.timestamps
    end

    add_index :professional_contracts, :contract_type_enum
    add_index :professional_contracts, :payment_type
  end
end

