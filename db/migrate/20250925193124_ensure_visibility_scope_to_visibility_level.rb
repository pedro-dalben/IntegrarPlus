class EnsureVisibilityScopeToVisibilityLevel < ActiveRecord::Migration[8.0]
  def up
    # Verificar se a coluna visibility_scope ainda existe
    if column_exists?(:events, :visibility_scope)
      # Se existe, renomear para visibility_level
      rename_column :events, :visibility_scope, :visibility_level
      puts '✅ Coluna visibility_scope renomeada para visibility_level'
    elsif column_exists?(:events, :visibility_level)
      # Se visibility_level já existe, não fazer nada
      puts '✅ Coluna visibility_level já existe - migração já executada'
    else
      # Se nenhuma das duas existe, criar visibility_level
      add_column :events, :visibility_level, :integer, default: 0, null: false
      puts '✅ Coluna visibility_level criada'
    end

    # Garantir que o índice existe
    return if index_exists?(:events, %i[professional_id visibility_level])

    add_index :events, %i[professional_id visibility_level]
    puts '✅ Índice para visibility_level criado'
  end

  def down
    # Reverter apenas se visibility_level existir
    rename_column :events, :visibility_level, :visibility_scope if column_exists?(:events, :visibility_level)

    # Remover índice se existir
    return unless index_exists?(:events, %i[professional_id visibility_scope])

    remove_index :events, %i[professional_id visibility_scope]
  end
end
