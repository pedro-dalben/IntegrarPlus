# frozen_string_literal: true

class AddMissingBirthFieldsToAnamneses < ActiveRecord::Migration[8.0]
  def change
    change_table :anamneses, bulk: true do |t|
      t.boolean :cord_around_neck
      t.boolean :cyanotic
    end
  end
end

