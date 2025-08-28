# frozen_string_literal: true

class RenamePortugueseFieldsToEnglishInProfessionals < ActiveRecord::Migration[8.0]
  def up
    # Remove old indexes first
    remove_index :professionals, :cep if index_exists?(:professionals, :cep)
    remove_index :professionals, :cidade if index_exists?(:professionals, :cidade)
    remove_index :professionals, :uf if index_exists?(:professionals, :uf)

    # Rename columns
    rename_column :professionals, :cep, :zip_code
    rename_column :professionals, :logradouro, :street
    rename_column :professionals, :bairro, :neighborhood
    rename_column :professionals, :cidade, :city
    rename_column :professionals, :uf, :state

    # Add new indexes
    add_index :professionals, :zip_code
    add_index :professionals, :city
    add_index :professionals, :state
  end

  def down
    # Remove new indexes
    remove_index :professionals, :zip_code if index_exists?(:professionals, :zip_code)
    remove_index :professionals, :city if index_exists?(:professionals, :city)
    remove_index :professionals, :state if index_exists?(:professionals, :state)

    # Rename columns back
    rename_column :professionals, :zip_code, :cep
    rename_column :professionals, :street, :logradouro
    rename_column :professionals, :neighborhood, :bairro
    rename_column :professionals, :city, :cidade
    rename_column :professionals, :state, :uf

    # Add old indexes back
    add_index :professionals, :cep
    add_index :professionals, :cidade
    add_index :professionals, :uf
  end
end
