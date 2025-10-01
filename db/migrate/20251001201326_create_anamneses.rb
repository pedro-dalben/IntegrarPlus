class CreateAnamneses < ActiveRecord::Migration[8.0]
  def change
    create_table :anamneses do |t|
      # Relacionamentos
      t.references :beneficiary, null: false, foreign_key: true
      t.references :professional, null: false, foreign_key: { to_table: :users }
      t.references :portal_intake, null: true, foreign_key: true

      # Campos de data
      t.datetime :data_realizada, null: false

      # Dados da família - Pai
      t.string :nome_pai
      t.date :data_nascimento_pai
      t.string :escolaridade_pai
      t.string :profissao_pai

      # Dados da família - Mãe
      t.string :nome_mae
      t.date :data_nascimento_mae
      t.string :escolaridade_mae
      t.string :profissao_mae

      # Dados da família - Responsável
      t.string :nome_responsavel
      t.date :data_nascimento_responsavel
      t.string :escolaridade_responsavel
      t.string :profissao_responsavel

      # Dados escolares
      t.boolean :frequenta_escola, default: false
      t.string :nome_escola
      t.string :periodo_escola # manha, tarde

      # Motivo do encaminhamento
      t.string :motivo_encaminhamento # aba, equipe_multi, aba_equipe_multi
      t.boolean :liminar, default: false
      t.string :local_atendimento # domiciliar, clinica, domiciliar_clinica, etc
      t.integer :horas_pacote_encaminhado # 5-40

      # Especialidades (JSON)
      t.json :especialidades

      # Diagnóstico
      t.boolean :diagnostico_concluido, default: false
      t.string :medico_responsavel

      # Tratamentos
      t.boolean :ja_realizou_tratamento, default: false
      t.json :tratamentos_anteriores
      t.boolean :vai_continuar_externo, default: false
      t.json :tratamentos_externos

      # Horários
      t.json :melhor_horario
      t.json :horario_impossivel

      # Status
      t.string :status, default: 'pendente' # pendente, em_andamento, concluida

      # Campos de auditoria
      t.references :created_by_professional, null: true, foreign_key: { to_table: :users }
      t.references :updated_by_professional, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    # Índices para performance
    add_index :anamneses, :data_realizada
    add_index :anamneses, :status
    add_index :anamneses, :created_at
    add_index :anamneses, %i[professional_id data_realizada]
    add_index :anamneses, %i[beneficiary_id status]
  end
end
