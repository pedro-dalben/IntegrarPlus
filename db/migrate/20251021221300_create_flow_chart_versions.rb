class CreateFlowChartVersions < ActiveRecord::Migration[8.0]
  def change
    create_table :flow_chart_versions do |t|
      t.references :flow_chart, null: false, foreign_key: true
      t.integer :data_format, default: 0, null: false
      t.text :data, limit: 16777215
      t.integer :version, null: false
      t.text :notes
      t.bigint :created_by_id, null: false

      t.timestamps
    end

    add_index :flow_chart_versions, :version
    add_index :flow_chart_versions, :created_by_id
    add_index :flow_chart_versions, [:flow_chart_id, :version], unique: true
  end
end
