# frozen_string_literal: true

class RenameVisibilityScopeToVisibilityLevel < ActiveRecord::Migration[8.0]
  def up
    return unless column_exists?(:events, :visibility_scope)

    rename_column :events, :visibility_scope, :visibility_level
  end

  def down
    return unless column_exists?(:events, :visibility_level)

    rename_column :events, :visibility_level, :visibility_scope
  end
end
