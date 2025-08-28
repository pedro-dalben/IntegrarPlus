# frozen_string_literal: true

class AddEnderecoToProfessionals < ActiveRecord::Migration[8.0]
  def change
    add_column :professionals, :cep, :string, limit: 9
    add_column :professionals, :logradouro, :string
    add_column :professionals, :bairro, :string
    add_column :professionals, :cidade, :string
    add_column :professionals, :uf, :string, limit: 2
    add_column :professionals, :latitude, :decimal, precision: 10, scale: 8
    add_column :professionals, :longitude, :decimal, precision: 11, scale: 8

    add_index :professionals, :cep
    add_index :professionals, :cidade
    add_index :professionals, :uf
  end
end
