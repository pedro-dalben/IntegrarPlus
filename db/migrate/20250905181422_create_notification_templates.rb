class CreateNotificationTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_templates do |t|
      t.string :name, null: false
      t.string :type, null: false
      t.string :channel, null: false
      t.string :subject
      t.text :body, null: false
      t.json :variables
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :notification_templates, [:type, :channel]
    add_index :notification_templates, :active
  end
end
