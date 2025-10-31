# frozen_string_literal: true

class CreateBeneficiaryTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :beneficiary_tickets do |t|
      t.references :beneficiary, null: false, foreign_key: true
      t.references :assigned_professional, null: true, foreign_key: { to_table: :professionals }
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :beneficiary_tickets, %i[beneficiary_id status]
  end
end
