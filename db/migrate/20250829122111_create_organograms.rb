class CreateOrganograms < ActiveRecord::Migration[8.0]
  def change
    create_table :organograms do |t|
      t.string :name, null: false
      t.jsonb :data, default: { nodes: [], links: [] }
      t.jsonb :settings, default: {}
      t.datetime :published_at
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :organograms, :name
    add_index :organograms, :published_at
  end
end
