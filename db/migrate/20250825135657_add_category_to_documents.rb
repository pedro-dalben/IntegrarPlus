class AddCategoryToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :category, :integer, default: 0, null: false
    add_index :documents, :category
  end
end
