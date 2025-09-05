class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :type, null: false
      t.string :title, null: false
      t.text :message, null: false
      t.json :metadata
      t.boolean :read, default: false
      t.datetime :read_at
      t.datetime :scheduled_at
      t.string :status, default: 'pending'
      t.string :channel, default: 'email'
      t.datetime :sent_at
      t.text :error_message

      t.timestamps
    end

    add_index :notifications, [:user_id, :read]
    add_index :notifications, [:type, :status]
    add_index :notifications, :scheduled_at
    add_index :notifications, :created_at
  end
end
