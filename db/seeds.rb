# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Carregar seeds específicos
load(Rails.root.join('db/seeds/permissionamento_setup.rb'))
load(Rails.root.join('db/seeds/groups_setup.rb'))
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
    specialization = Specialization.find_or_create_by!(name: spec_name)
    specialization.specialities << speciality unless specialization.specialities.include?(speciality)
  end
end

# Grupos padrão
groups_data = [
  { name: 'Administradores', is_admin: true },
  { name: 'Coordenadores', is_admin: false },
  { name: 'Profissionais', is_admin: false },
  { name: 'Estagiários', is_admin: false },
  { name: 'Voluntários', is_admin: false }
]

groups_data.each do |group_data|
  Group.find_or_create_by!(name: group_data[:name]) do |group|
    group.is_admin = group_data[:is_admin]
  end
end

# Profissional admin padrão (fonte única de verdade)
admin_professional = Professional.find_or_create_by!(email: 'admin@integrarplus.com') do |professional|
  professional.full_name = 'Administrador do Sistema'
  professional.cpf = '11111111111'
  professional.phone = '(11) 99999-9999'
  professional.active = true
end

# Cria usuário para o profissional admin se não existir
unless admin_professional.user
  admin_user = User.create!(
    email: admin_professional.email,
    password: '123456',
    password_confirmation: '123456',
    professional: admin_professional
  )
  puts "Usuário criado para admin: #{admin_user.email} com senha: 123456"
end

# Associa o profissional admin ao grupo Administradores
admin_group = Group.find_by(name: 'Administradores')
if admin_group && !admin_professional.groups.include?(admin_group)
  admin_professional.professional_groups.create!(group: admin_group)
  puts "Profissional admin associado ao grupo: #{admin_group.name}"
end

# Carrega seeds para usuários externos (operadoras)
load(Rails.root.join('db/seeds/external_users.rb'))

# Carrega seeds para entradas do portal
load(Rails.root.join('db/seeds/portal_intakes.rb'))
