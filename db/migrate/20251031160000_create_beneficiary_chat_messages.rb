# frozen_string_literal: true

class CreateBeneficiaryChatMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :beneficiary_chat_messages do |t|
      t.references :beneficiary, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end

    add_index :beneficiary_chat_messages, %i[beneficiary_id created_at]
  end
end
