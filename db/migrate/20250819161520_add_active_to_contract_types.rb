class AddActiveToContractTypes < ActiveRecord::Migration[8.0]
  def change
    add_column :contract_types, :active, :boolean, default: true, null: false
  end
end
