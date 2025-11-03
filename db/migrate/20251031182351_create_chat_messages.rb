# frozen_string_literal: true

class CreateChatMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :chat_messages do |t|
      t.references :conversation, null: false, foreign_key: true, index: true
      t.bigint :message_number, null: false
      t.string :sender_type, null: false
      t.bigint :sender_id, null: false
      t.integer :content_type, default: 0, null: false
      t.text :body, null: false
      t.jsonb :metadata, default: {}, null: false
      t.datetime :edited_at
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :chat_messages, %i[conversation_id message_number], unique: true,
                                                                  name: 'idx_chat_messages_conversation_number_unique'
    add_index :chat_messages, %i[conversation_id created_at], order: { created_at: :desc },
                                                              where: 'deleted_at IS NULL', name: 'idx_chat_messages_conversation_created_desc'
    add_index :chat_messages, %i[sender_id created_at], order: { created_at: :desc },
                                                        name: 'idx_chat_messages_sender_created_desc'

    add_check_constraint :chat_messages, 'content_type IN (0, 1, 2, 3, 4)', name: 'check_content_type'
  end
end
