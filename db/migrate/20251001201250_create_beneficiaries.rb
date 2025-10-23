# frozen_string_literal: true

class CreateBeneficiaries < ActiveRecord::Migration[8.0]
  def change
    create_table :beneficiaries do |t|
      # Relacionamentos
      t.references :portal_intake, null: true, foreign_key: true
      t.references :created_by_professional, null: true, foreign_key: { to_table: :users }
      t.references :updated_by_professional, null: true, foreign_key: { to_table: :users }

      # Campos básicos
      t.string :nome, null: false
      t.date :data_nascimento, null: false
      t.string :cpf, null: false
      t.string :telefone
      t.string :telefone_secundario
      t.string :email
      t.string :email_secundario
      t.string :whatsapp

      # Campos de endereço
      t.text :endereco
      t.string :numero
      t.string :complemento
      t.string :bairro
      t.string :cidade
      t.string :estado
      t.string :cep
      t.string :referencia

      # Campos de responsável
      t.string :nome_responsavel
      t.string :telefone_responsavel
      t.string :parentesco
      t.string :cpf_responsavel
      t.string :rg_responsavel
      t.string :profissao_responsavel
      t.decimal :renda_familiar, precision: 10, scale: 2

      # Campos de escola
      t.boolean :frequenta_escola, default: false
      t.string :nome_escola
      t.string :periodo_escola # manha, tarde

      # Campos de saúde
      t.string :plano_saude
      t.string :numero_carteirinha
      t.text :alergias
      t.text :medicamentos_uso_continuo
      t.text :condicoes_especiais

      # Campos de identificação
      t.string :cadastro_integrar, null: false # CI00000
      t.string :numero_prontuario
      t.string :foto # URL ou path da foto

      # Campos de status
      t.string :status, default: 'ativo' # ativo, inativo, suspenso, transferido
      t.date :data_inicio_atendimento
      t.date :data_fim_atendimento
      t.text :motivo_inativacao

      t.timestamps
    end

    # Índices para performance
    add_index :beneficiaries, :cpf, unique: true
    add_index :beneficiaries, :cadastro_integrar, unique: true
    add_index :beneficiaries, :numero_prontuario, unique: true
    add_index :beneficiaries, :nome
    add_index :beneficiaries, :data_nascimento
    add_index :beneficiaries, :status
    add_index :beneficiaries, :created_at
  end
end
