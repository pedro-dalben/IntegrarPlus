class RenameVisibilityScopeToVisibilityLevel < ActiveRecord::Migration[8.0]
  def change
    rename_column :events, :visibility_scope, :visibility_level
  end
end
