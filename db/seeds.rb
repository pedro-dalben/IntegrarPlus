# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Tipos de contratação padrão
contract_types = [
  {
    name: 'CLT',
    requires_company: false,
    requires_cnpj: false,
    description: 'Consolidação das Leis do Trabalho - Contrato de trabalho regido pela CLT'
  },
  {
    name: 'PJ',
    requires_company: true,
    requires_cnpj: true,
    description: 'Pessoa Jurídica - Contrato de prestação de serviços como empresa'
  },
  {
    name: 'Autônomo',
    requires_company: false,
    requires_cnpj: false,
    description: 'Profissional autônomo sem vínculo empregatício'
  }
]

contract_types.each do |contract_type_attrs|
  ContractType.find_or_create_by!(name: contract_type_attrs[:name]) do |contract_type|
    contract_type.assign_attributes(contract_type_attrs)
  end
end

# Especialidades e Especializações padrão
specialities_data = [
  {
    name: 'Fonoaudiologia',
    specializations: [
      'Linguagem',
      'Motricidade Orofacial',
      'Neurodesenvolvimento',
      'Audiologia',
      'Voz'
    ]
  },
  {
    name: 'Psicologia',
    specializations: [
      'ABA',
      'Neuropsicologia',
      'Terapia Cognitivo-Comportamental',
      'Psicopedagogia',
      'Psicologia Clínica'
    ]
  },
  {
    name: 'Terapia Ocupacional',
    specializations: [
      'Integração Sensorial',
      'Pediatria',
      'Reabilitação Neurológica',
      'Saúde Mental',
      'Reabilitação Física'
    ]
  }
]

specialities_data.each do |speciality_data|
  speciality = Speciality.find_or_create_by!(name: speciality_data[:name])

  speciality_data[:specializations].each do |spec_name|
    Specialization.find_or_create_by!(name: spec_name, speciality: speciality)
  end
end

# Grupos padrão
groups = %w[
  Administradores
  Coordenadores
  Profissionais
  Estagiários
  Voluntários
]

groups.each do |group_name|
  Group.find_or_create_by!(name: group_name)
end

# Usuário admin padrão
admin_user = User.find_or_create_by!(email: 'admin@integrarplus.com') do |user|
  user.name = 'Administrador'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.confirmed_at = Time.current
end
