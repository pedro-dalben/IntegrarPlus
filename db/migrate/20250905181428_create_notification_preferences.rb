class CreateNotificationPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.string :type, null: false
      t.boolean :email_enabled, default: true
      t.boolean :sms_enabled, default: false
      t.boolean :push_enabled, default: true
      t.json :settings

      t.timestamps
    end

    add_index :notification_preferences, [:user_id, :type], unique: true
  end
end
