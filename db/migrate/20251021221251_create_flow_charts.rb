class CreateFlowCharts < ActiveRecord::Migration[8.0]
  def change
    create_table :flow_charts do |t|
      t.string :title, null: false
      t.text :description
      t.integer :status, default: 0, null: false
      t.bigint :current_version_id
      t.bigint :created_by_id, null: false
      t.bigint :updated_by_id

      t.timestamps
    end

    add_index :flow_charts, :status
    add_index :flow_charts, :created_by_id
    add_index :flow_charts, :updated_by_id
    add_index :flow_charts, :current_version_id
  end
end
