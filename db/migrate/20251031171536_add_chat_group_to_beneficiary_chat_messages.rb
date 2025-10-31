# frozen_string_literal: true

class AddChatGroupToBeneficiaryChatMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :beneficiary_chat_messages, :chat_group, :string, default: 'professionals_only', null: false
    add_index :beneficiary_chat_messages, %i[beneficiary_id chat_group created_at]
  end
end
