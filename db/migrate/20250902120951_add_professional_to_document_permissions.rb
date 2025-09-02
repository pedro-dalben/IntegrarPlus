# frozen_string_literal: true

class AddProfessionalToDocumentPermissions < ActiveRecord::Migration[8.0]
  def up
    # Adicionar coluna professional_id (nullable inicialmente)
    add_reference :document_permissions, :professional, null: true, foreign_key: true

    # Migrar dados existentes de user_id para professional_id
    execute <<-SQL.squish
      UPDATE document_permissions#{' '}
      SET professional_id = (
        SELECT professionals.id#{' '}
        FROM professionals#{' '}
        WHERE professionals.user_id = document_permissions.user_id
      )
      WHERE user_id IS NOT NULL
    SQL

    # Remover registros que não têm professional associado
    execute 'DELETE FROM document_permissions WHERE user_id IS NOT NULL AND professional_id IS NULL'

    # Atualizar constraint para exigir professional_id ou group_id
    remove_check_constraint :document_permissions, name: 'check_user_or_group_present'
    add_check_constraint :document_permissions, 'professional_id IS NOT NULL OR group_id IS NOT NULL',
                         name: 'check_professional_or_group_present'

    # Atualizar índices
    remove_index :document_permissions, name: 'index_document_permissions_on_document_id_and_user_id'
    remove_index :document_permissions, name: 'index_document_permissions_on_user_id'
    add_index :document_permissions, %i[document_id professional_id], unique: true,
                                                                      where: '(professional_id IS NOT NULL)', name: 'index_document_permissions_on_document_id_and_professional_id'

    # Remover coluna user_id
    remove_reference :document_permissions, :user, foreign_key: true
  end

  def down
    # Reverter: adicionar user_id de volta
    add_reference :document_permissions, :user, null: true, foreign_key: true

    # Migrar dados de volta
    execute <<-SQL.squish
      UPDATE document_permissions#{' '}
      SET user_id = (
        SELECT professionals.user_id#{' '}
        FROM professionals#{' '}
        WHERE professionals.id = document_permissions.professional_id
      )
      WHERE professional_id IS NOT NULL
    SQL

    # Reverter constraints e índices
    remove_check_constraint :document_permissions, name: 'check_professional_or_group_present'
    add_check_constraint :document_permissions, 'user_id IS NOT NULL OR group_id IS NOT NULL',
                         name: 'check_user_or_group_present'

    remove_index :document_permissions, name: 'index_document_permissions_on_document_id_and_professional_id'
    add_index :document_permissions, %i[document_id user_id], unique: true, where: '(user_id IS NOT NULL)',
                                                              name: 'index_document_permissions_on_document_id_and_user_id'
    add_index :document_permissions, :user_id

    # Remover coluna professional_id
    remove_reference :document_permissions, :professional, foreign_key: true
  end
end
