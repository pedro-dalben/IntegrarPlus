# frozen_string_literal: true

class AddActiveToSpecialities < ActiveRecord::Migration[8.0]
  def change
    add_column :specialities, :active, :boolean, default: true, null: false
  end
end
