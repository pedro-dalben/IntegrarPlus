class RenameBeneficiaryFieldsToEnglish < ActiveRecord::Migration[8.0]
  def change
    # Rename basic fields
    rename_column :beneficiaries, :nome, :name
    rename_column :beneficiaries, :data_nascimento, :birth_date
    rename_column :beneficiaries, :telefone, :phone
    rename_column :beneficiaries, :telefone_secundario, :secondary_phone
    rename_column :beneficiaries, :email_secundario, :secondary_email
    rename_column :beneficiaries, :whatsapp, :whatsapp_number

    # Rename address fields
    rename_column :beneficiaries, :endereco, :address
    rename_column :beneficiaries, :numero, :address_number
    rename_column :beneficiaries, :complemento, :address_complement
    rename_column :beneficiaries, :bairro, :neighborhood
    rename_column :beneficiaries, :cidade, :city
    rename_column :beneficiaries, :estado, :state
    rename_column :beneficiaries, :cep, :zip_code
    rename_column :beneficiaries, :referencia, :address_reference

    # Rename responsible fields
    rename_column :beneficiaries, :nome_responsavel, :responsible_name
    rename_column :beneficiaries, :telefone_responsavel, :responsible_phone
    rename_column :beneficiaries, :parentesco, :relationship
    rename_column :beneficiaries, :cpf_responsavel, :responsible_cpf
    rename_column :beneficiaries, :rg_responsavel, :responsible_rg
    rename_column :beneficiaries, :profissao_responsavel, :responsible_profession
    rename_column :beneficiaries, :renda_familiar, :family_income

    # Rename school fields
    rename_column :beneficiaries, :frequenta_escola, :attends_school
    rename_column :beneficiaries, :nome_escola, :school_name
    rename_column :beneficiaries, :periodo_escola, :school_period

    # Rename health fields
    rename_column :beneficiaries, :plano_saude, :health_plan
    rename_column :beneficiaries, :numero_carteirinha, :health_card_number
    rename_column :beneficiaries, :alergias, :allergies
    rename_column :beneficiaries, :medicamentos_uso_continuo, :continuous_medications
    rename_column :beneficiaries, :condicoes_especiais, :special_conditions

    # Rename identification fields
    rename_column :beneficiaries, :cadastro_integrar, :integrar_code
    rename_column :beneficiaries, :numero_prontuario, :medical_record_number
    rename_column :beneficiaries, :foto, :photo

    # Rename status fields
    rename_column :beneficiaries, :data_inicio_atendimento, :treatment_start_date
    rename_column :beneficiaries, :data_fim_atendimento, :treatment_end_date
    rename_column :beneficiaries, :motivo_inativacao, :inactivation_reason
  end
end
