class CreateAgendaTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :agenda_templates do |t|
      t.string :name, null: false
      t.text :description
      t.integer :category, null: false, default: 0
      t.integer :visibility, null: false, default: 0
      t.json :template_data, null: false
      t.integer :usage_count, default: 0
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :agenda_templates, :category
    add_index :agenda_templates, :visibility
    add_index :agenda_templates, :usage_count
    add_index :agenda_templates, [:created_by_id, :visibility]
  end
end
