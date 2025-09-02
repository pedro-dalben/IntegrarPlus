# frozen_string_literal: true

class CreateJourneyEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :journey_events do |t|
      t.references :portal_intake, null: false, foreign_key: true
      t.string :event_type, null: false
      t.jsonb :metadata, default: {}
      t.timestamps
    end

    add_index :journey_events, :event_type
    add_index :journey_events, :created_at
  end
end
