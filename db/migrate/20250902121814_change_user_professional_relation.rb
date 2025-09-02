# frozen_string_literal: true

class ChangeUserProfessionalRelation < ActiveRecord::Migration[8.0]
  def up
    # Remover a foreign key atual se existir
    remove_foreign_key :professionals, :users if foreign_key_exists?(:professionals, :users, column: :user_id)

    # Adicionar professional_id na tabela users (nullable inicialmente)
    add_reference :users, :professional, null: true, foreign_key: true

    # Remover tabela memberships primeiro (grupos agora são apenas no Professional)
    drop_table :memberships if table_exists?(:memberships)

    # Migrar dados: cada User deve apontar para seu Professional
    execute <<-SQL.squish
      UPDATE users#{' '}
      SET professional_id = (
        SELECT professionals.id#{' '}
        FROM professionals#{' '}
        WHERE professionals.user_id = users.id
      )
      WHERE EXISTS (
        SELECT 1 FROM professionals WHERE professionals.user_id = users.id
      )
    SQL

    # Remover users que não têm professional associado
    execute 'DELETE FROM users WHERE professional_id IS NULL'

    # Tornar professional_id obrigatório após migração
    change_column_null :users, :professional_id, false

    # Remover user_id da tabela professionals
    remove_column :professionals, :user_id
  end

  def down
    # Reverter: adicionar user_id de volta na tabela professionals
    add_reference :professionals, :user, null: true, foreign_key: true

    # Recriar tabela memberships
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.timestamps
    end

    add_index :memberships, %i[user_id group_id], unique: true

    # Migrar dados de volta
    execute <<-SQL.squish
      UPDATE professionals#{' '}
      SET user_id = (
        SELECT users.id#{' '}
        FROM users#{' '}
        WHERE users.professional_id = professionals.id
      )
      WHERE EXISTS (
        SELECT 1 FROM users WHERE users.professional_id = professionals.id
      )
    SQL

    # Remover professional_id da tabela users
    remove_reference :users, :professional, foreign_key: true
  end
end
