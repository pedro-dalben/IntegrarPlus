class CreateInvites < ActiveRecord::Migration[8.0]
  def change
    create_table :invites do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :confirmed_at
      t.integer :attempts_count, default: 0

      t.timestamps
    end

    add_index :invites, :token, unique: true
    add_index :invites, :expires_at
  end
end
