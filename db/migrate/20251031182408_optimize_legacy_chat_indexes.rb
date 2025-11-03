# frozen_string_literal: true

class OptimizeLegacyChatIndexes < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    add_index :beneficiary_chat_messages,
              %i[beneficiary_id chat_group created_at],
              order: { created_at: :desc },
              algorithm: :concurrently,
              if_not_exists: true,
              name: 'idx_bcm_beneficiary_group_created_desc'

    add_index :beneficiary_chat_messages,
              %i[user_id created_at],
              order: { created_at: :desc },
              algorithm: :concurrently,
              if_not_exists: true,
              name: 'idx_bcm_sender_created_desc'
  end

  def down
    remove_index :beneficiary_chat_messages,
                 name: 'idx_bcm_beneficiary_group_created_desc',
                 algorithm: :concurrently,
                 if_exists: true

    remove_index :beneficiary_chat_messages,
                 name: 'idx_bcm_sender_created_desc',
                 algorithm: :concurrently,
                 if_exists: true
  end
end
