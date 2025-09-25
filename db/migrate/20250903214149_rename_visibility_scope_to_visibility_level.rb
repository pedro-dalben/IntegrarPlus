class RenameVisibilityScopeToVisibilityLevel < ActiveRecord::Migration[8.0]
  def up
    if column_exists?(:events, :visibility_scope)
      rename_column :events, :visibility_scope, :visibility_level
    end
  end

  def down
    if column_exists?(:events, :visibility_level)
      rename_column :events, :visibility_level, :visibility_scope
    end
  end
end
