# frozen_string_literal: true

class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.string :identifier, null: false
      t.string :service, null: false
      t.string :context_type, null: false
      t.bigint :context_id, null: false
      t.bigint :scope_id
      t.string :scope
      t.integer :conversation_type, default: 0, null: false
      t.bigint :next_message_number, default: 1, null: false
      t.bigint :messages_count, default: 0, null: false
      t.bigint :last_message_id
      t.datetime :last_message_at
      t.integer :status, default: 0, null: false
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
      t.datetime :deleted_at
    end

    add_index :conversations, :identifier, unique: true
    add_index :conversations, :service
    add_index :conversations, %i[context_type context_id]
    add_index :conversations, :scope_id
    add_index :conversations, :scope
    add_index :conversations, :last_message_at
    add_index :conversations, %i[service updated_at]
    add_index :conversations, %i[context_type context_id status last_message_at], order: { last_message_at: :desc },
                                                                                  name: 'idx_conversations_context_status_last_message'
    add_index :conversations, :metadata, using: :gin
  end
end
