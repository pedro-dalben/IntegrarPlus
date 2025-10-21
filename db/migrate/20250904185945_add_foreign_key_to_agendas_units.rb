# frozen_string_literal: true

class AddForeignKeyToAgendasUnits < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :agendas, :units
  end
end
