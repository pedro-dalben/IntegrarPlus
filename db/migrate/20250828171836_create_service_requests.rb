# frozen_string_literal: true

class CreateServiceRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :service_requests do |t|
      t.references :external_user, null: false, foreign_key: true
      t.string :convenio, null: false
      t.string :carteira_codigo, null: false
      t.string :tipo_convenio, null: false
      t.string :cpf, null: false
      t.string :nome, null: false
      t.date :data_nascimento, null: false
      t.text :endereco, null: false
      t.string :responsavel
      t.date :data_encaminhamento, null: false
      t.string :status, default: 'aguardando', null: false

      t.timestamps
    end

    add_index :service_requests, :status
    add_index :service_requests, :data_encaminhamento
    add_index :service_requests, :cpf
  end
end
