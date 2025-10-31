# frozen_string_literal: true

class CreateBeneficiaryChatMessageReads < ActiveRecord::Migration[8.0]
  def change
    create_table :beneficiary_chat_message_reads do |t|
      t.references :beneficiary_chat_message, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :read_at, null: false

      t.timestamps
    end

    add_index :beneficiary_chat_message_reads, %i[beneficiary_chat_message_id user_id], unique: true,
                                                                                        name: 'index_bcm_reads_on_message_and_user'
    add_index :beneficiary_chat_message_reads, :read_at
  end
end
