# frozen_string_literal: true

class AddReleasedVersionToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :released_version, :string
  end
end
