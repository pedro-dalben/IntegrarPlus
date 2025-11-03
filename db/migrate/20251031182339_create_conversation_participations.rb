# frozen_string_literal: true

class CreateConversationParticipations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversation_participations do |t|
      t.references :conversation, null: false, foreign_key: true, index: true
      t.string :participant_type, null: false
      t.bigint :participant_id, null: false
      t.integer :role, default: 0, null: false
      t.bigint :last_read_message_number, default: 0, null: false
      t.integer :unread_count, default: 0, null: false
      t.boolean :notifications_enabled, default: true, null: false
      t.jsonb :notification_preferences, default: {}, null: false
      t.datetime :muted_until
      t.datetime :joined_at, default: -> { 'CURRENT_TIMESTAMP' }, null: false
      t.datetime :left_at

      t.timestamps
    end

    add_index :conversation_participations, %i[conversation_id participant_type participant_id], unique: true,
                                                                                                 where: 'left_at IS NULL', name: 'idx_participations_conversation_participant_unique'
    add_index :conversation_participations, %i[conversation_id participant_id],
              name: 'idx_participations_conversation_participant_read'

    add_check_constraint :conversation_participations, 'role IN (0, 1, 2, 3)', name: 'check_role'
  end
end
