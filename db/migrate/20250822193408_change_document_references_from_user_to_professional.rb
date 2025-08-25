# frozen_string_literal: true

class ChangeDocumentReferencesFromUserToProfessional < ActiveRecord::Migration[8.0]
  def up
    # 1. Adicionar novas colunas para Professional
    add_reference :documents, :author_professional, null: true, foreign_key: { to_table: :professionals }
    add_reference :document_responsibles, :professional, null: true, foreign_key: { to_table: :professionals }
    add_reference :document_tasks, :created_by_professional, null: true, foreign_key: { to_table: :professionals }
    add_reference :document_tasks, :assigned_to_professional, null: true, foreign_key: { to_table: :professionals }
    add_reference :document_tasks, :completed_by_professional, null: true, foreign_key: { to_table: :professionals }
    add_reference :document_status_logs, :professional, null: true, foreign_key: { to_table: :professionals }
    add_reference :document_releases, :released_by_professional, null: true, foreign_key: { to_table: :professionals }
    add_reference :document_versions, :created_by_professional, null: true, foreign_key: { to_table: :professionals }

    # 2. Migrar dados existentes (assumindo que Professional tem user_id)
    execute <<-SQL.squish
      UPDATE documents#{' '}
      SET author_professional_id = (
        SELECT id FROM professionals WHERE user_id = documents.author_id
      )
      WHERE author_id IS NOT NULL;
    SQL

    execute <<-SQL.squish
      UPDATE document_responsibles#{' '}
      SET professional_id = (
        SELECT id FROM professionals WHERE user_id = document_responsibles.user_id
      )
      WHERE user_id IS NOT NULL;
    SQL

    execute <<-SQL.squish
      UPDATE document_tasks#{' '}
      SET created_by_professional_id = (
        SELECT id FROM professionals WHERE user_id = document_tasks.created_by_id
      )
      WHERE created_by_id IS NOT NULL;
    SQL

    execute <<-SQL.squish
      UPDATE document_tasks#{' '}
      SET assigned_to_professional_id = (
        SELECT id FROM professionals WHERE user_id = document_tasks.assigned_to_id
      )
      WHERE assigned_to_id IS NOT NULL;
    SQL

    execute <<-SQL.squish
      UPDATE document_tasks#{' '}
      SET completed_by_professional_id = (
        SELECT id FROM professionals WHERE user_id = document_tasks.completed_by_id
      )
      WHERE completed_by_id IS NOT NULL;
    SQL

    execute <<-SQL.squish
      UPDATE document_status_logs#{' '}
      SET professional_id = (
        SELECT id FROM professionals WHERE user_id = document_status_logs.user_id
      )
      WHERE user_id IS NOT NULL;
    SQL

    execute <<-SQL.squish
      UPDATE document_releases#{' '}
      SET released_by_professional_id = (
        SELECT id FROM professionals WHERE user_id = document_releases.released_by_id
      )
      WHERE released_by_id IS NOT NULL;
    SQL

    execute <<-SQL.squish
      UPDATE document_versions#{' '}
      SET created_by_professional_id = (
        SELECT id FROM professionals WHERE user_id = document_versions.created_by_id
      )
      WHERE created_by_id IS NOT NULL;
    SQL

    # 3. Remover colunas antigas
    remove_reference :documents, :author, foreign_key: { to_table: :users }
    remove_reference :document_responsibles, :user, foreign_key: { to_table: :users }
    remove_reference :document_tasks, :created_by, foreign_key: { to_table: :users }
    remove_reference :document_tasks, :assigned_to, foreign_key: { to_table: :users }
    remove_reference :document_tasks, :completed_by, foreign_key: { to_table: :users }
    remove_reference :document_status_logs, :user, foreign_key: { to_table: :users }
    remove_reference :document_releases, :released_by, foreign_key: { to_table: :users }
    remove_reference :document_versions, :created_by, foreign_key: { to_table: :users }

    # 4. Tornar as novas colunas obrigatórias
    change_column_null :documents, :author_professional_id, false
    change_column_null :document_responsibles, :professional_id, false
    change_column_null :document_tasks, :created_by_professional_id, false
    change_column_null :document_status_logs, :professional_id, false
    change_column_null :document_releases, :released_by_professional_id, false
    change_column_null :document_versions, :created_by_professional_id, false
  end

  def down
    # 1. Adicionar colunas antigas de volta
    add_reference :documents, :author, null: true, foreign_key: { to_table: :users }
    add_reference :document_responsibles, :user, null: true, foreign_key: { to_table: :users }
    add_reference :document_tasks, :created_by, null: true, foreign_key: { to_table: :users }
    add_reference :document_tasks, :assigned_to, null: true, foreign_key: { to_table: :users }
    add_reference :document_tasks, :completed_by, null: true, foreign_key: { to_table: :users }
    add_reference :document_status_logs, :user, null: true, foreign_key: { to_table: :users }
    add_reference :document_releases, :released_by, null: true, foreign_key: { to_table: :users }
    add_reference :document_versions, :created_by, null: true, foreign_key: { to_table: :users }

    # 2. Migrar dados de volta
    execute <<-SQL.squish
      UPDATE documents#{' '}
      SET author_id = (
        SELECT user_id FROM professionals WHERE id = documents.author_professional_id
      )
      WHERE author_professional_id IS NOT NULL;
    SQL

    execute <<-SQL.squish
      UPDATE document_responsibles#{' '}
      SET user_id = (
        SELECT user_id FROM professionals WHERE id = document_responsibles.professional_id
      )
      WHERE professional_id IS NOT NULL;
    SQL

    execute <<-SQL.squish
      UPDATE document_tasks#{' '}
      SET created_by_id = (
        SELECT user_id FROM professionals WHERE id = document_tasks.created_by_professional_id
      )
      WHERE created_by_professional_id IS NOT NULL;
    SQL

    execute <<-SQL.squish
      UPDATE document_tasks#{' '}
      SET assigned_to_id = (
        SELECT user_id FROM professionals WHERE id = document_tasks.assigned_to_professional_id
      )
      WHERE assigned_to_professional_id IS NOT NULL;
    SQL

    execute <<-SQL.squish
      UPDATE document_tasks#{' '}
      SET completed_by_id = (
        SELECT user_id FROM professionals WHERE id = document_tasks.completed_by_professional_id
      )
      WHERE completed_by_professional_id IS NOT NULL;
    SQL

    execute <<-SQL.squish
      UPDATE document_status_logs#{' '}
      SET user_id = (
        SELECT user_id FROM professionals WHERE id = document_status_logs.professional_id
      )
      WHERE professional_id IS NOT NULL;
    SQL

    execute <<-SQL.squish
      UPDATE document_releases#{' '}
      SET released_by_id = (
        SELECT user_id FROM professionals WHERE id = document_releases.released_by_professional_id
      )
      WHERE released_by_professional_id IS NOT NULL;
    SQL

    execute <<-SQL.squish
      UPDATE document_versions#{' '}
      SET created_by_id = (
        SELECT user_id FROM professionals WHERE id = document_versions.created_by_professional_id
      )
      WHERE created_by_professional_id IS NOT NULL;
    SQL

    # 3. Remover colunas novas
    remove_reference :documents, :author_professional, foreign_key: { to_table: :professionals }
    remove_reference :document_responsibles, :professional, foreign_key: { to_table: :professionals }
    remove_reference :document_tasks, :created_by_professional, foreign_key: { to_table: :professionals }
    remove_reference :document_tasks, :assigned_to_professional, foreign_key: { to_table: :professionals }
    remove_reference :document_tasks, :completed_by_professional, foreign_key: { to_table: :professionals }
    remove_reference :document_status_logs, :professional, foreign_key: { to_table: :professionals }
    remove_reference :document_releases, :released_by_professional, foreign_key: { to_table: :professionals }
    remove_reference :document_versions, :created_by_professional, foreign_key: { to_table: :professionals }

    # 4. Tornar as colunas antigas obrigatórias
    change_column_null :documents, :author_id, false
    change_column_null :document_responsibles, :user_id, false
    change_column_null :document_tasks, :created_by_id, false
    change_column_null :document_status_logs, :user_id, false
    change_column_null :document_releases, :released_by_id, false
    change_column_null :document_versions, :created_by_id, false
  end
end
