# frozen_string_literal: true

class AddDedupeKeyToChatMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :chat_messages, :dedupe_key, :string
    add_index :chat_messages, :dedupe_key, unique: true, where: 'dedupe_key IS NOT NULL',
                                           name: 'idx_chat_messages_dedupe_key_unique'
  end
end
