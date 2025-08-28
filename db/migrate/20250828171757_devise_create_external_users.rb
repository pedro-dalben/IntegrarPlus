# frozen_string_literal: true

class DeviseCreateExternalUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :external_users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Campos específicos da operadora
      t.string :name, null: false
      t.string :company_name, null: false
      t.boolean :active, default: true, null: false

      t.timestamps null: false
    end

    add_index :external_users, :email,                unique: true
    add_index :external_users, :reset_password_token, unique: true
    # add_index :external_users, :confirmation_token,   unique: true
    # add_index :external_users, :unlock_token,         unique: true
  end
end
