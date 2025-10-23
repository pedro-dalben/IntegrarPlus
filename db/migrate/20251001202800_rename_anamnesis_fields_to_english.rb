# frozen_string_literal: true

class RenameAnamnesisFieldsToEnglish < ActiveRecord::Migration[8.0]
  def change
    # Rename date field
    rename_column :anamneses, :data_realizada, :performed_at

    # Rename family fields - Father
    rename_column :anamneses, :nome_pai, :father_name
    rename_column :anamneses, :data_nascimento_pai, :father_birth_date
    rename_column :anamneses, :escolaridade_pai, :father_education
    rename_column :anamneses, :profissao_pai, :father_profession

    # Rename family fields - Mother
    rename_column :anamneses, :nome_mae, :mother_name
    rename_column :anamneses, :data_nascimento_mae, :mother_birth_date
    rename_column :anamneses, :escolaridade_mae, :mother_education
    rename_column :anamneses, :profissao_mae, :mother_profession

    # Rename family fields - Responsible
    rename_column :anamneses, :nome_responsavel, :responsible_name
    rename_column :anamneses, :data_nascimento_responsavel, :responsible_birth_date
    rename_column :anamneses, :escolaridade_responsavel, :responsible_education
    rename_column :anamneses, :profissao_responsavel, :responsible_profession

    # Rename school fields
    rename_column :anamneses, :frequenta_escola, :attends_school
    rename_column :anamneses, :nome_escola, :school_name
    rename_column :anamneses, :periodo_escola, :school_period

    # Rename referral fields
    rename_column :anamneses, :motivo_encaminhamento, :referral_reason
    rename_column :anamneses, :liminar, :injunction
    rename_column :anamneses, :local_atendimento, :treatment_location
    rename_column :anamneses, :horas_pacote_encaminhado, :referral_hours

    # Rename specialties field
    rename_column :anamneses, :especialidades, :specialties

    # Rename diagnosis fields
    rename_column :anamneses, :diagnostico_concluido, :diagnosis_completed
    rename_column :anamneses, :medico_responsavel, :responsible_doctor

    # Rename treatment fields
    rename_column :anamneses, :ja_realizou_tratamento, :previous_treatment
    rename_column :anamneses, :tratamentos_anteriores, :previous_treatments
    rename_column :anamneses, :vai_continuar_externo, :continue_external_treatment
    rename_column :anamneses, :tratamentos_externos, :external_treatments

    # Rename schedule fields
    rename_column :anamneses, :melhor_horario, :preferred_schedule
    rename_column :anamneses, :horario_impossivel, :unavailable_schedule
  end
end
