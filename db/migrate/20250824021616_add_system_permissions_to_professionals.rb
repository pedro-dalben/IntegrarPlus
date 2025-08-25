# frozen_string_literal: true

class AddSystemPermissionsToProfessionals < ActiveRecord::Migration[8.0]
  def change
    add_column :professionals, :system_permissions, :integer, array: true, default: []
    add_index :professionals, :system_permissions, using: 'gin'
  end
end
