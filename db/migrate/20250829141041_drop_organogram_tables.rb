# frozen_string_literal: true

class DropOrganogramTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :organogram_members, if_exists: true
    drop_table :organograms, if_exists: true
  end
end
