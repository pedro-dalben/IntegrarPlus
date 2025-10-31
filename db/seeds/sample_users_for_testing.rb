# frozen_string_literal: true

Rails.logger.debug '==> Criando usuários de teste para permissões de beneficiário'

beneficiary = Beneficiary.first || Beneficiary.create!(
  name: 'Beneficiário Teste',
  birth_date: Date.new(2015, 1, 1),
  cpf: '123.456.789-00',
  integrar_code: 'CI99999',
  status: :active
)

def ensure_group(name)
  Group.find_or_create_by!(name: name)
end

group_profissionais = ensure_group('Profissionais')
group_secretarias = ensure_group('Secretárias')

def create_professional_user!(email:, full_name:, cpf:, groups: [])
  professional = Professional.find_or_create_by!(email: email) do |p|
    p.full_name = full_name
    p.cpf = cpf
    p.active = true
  end

  groups.each { |g| ProfessionalGroup.find_or_create_by!(professional: professional, group: g) }

  user = professional.user || User.create!(
    email: email,
    password: 'Senha@123',
    password_confirmation: 'Senha@123',
    professional: professional
  )

  { user: user, professional: professional }
end

# 1) Profissional com acesso total às abas
u1 = create_professional_user!(email: 'prof.total@example.com', full_name: 'Prof Total', cpf: '14538220620',
                               groups: [group_profissionais])

# 2) Secretária com acesso às abas
u2 = create_professional_user!(email: 'secretaria@example.com', full_name: 'Sec Teste', cpf: '15350946056',
                               groups: [group_secretarias])

# 3) Profissional sem permissões de abas
create_professional_user!(email: 'prof.sem.acesso@example.com', full_name: 'Prof Sem Acesso', cpf: '16899535009',
                          groups: [])

# Relacionar profissionais 1 e 2 ao beneficiário (para passar na relação do TabAccessService)
[u1[:professional], u2[:professional]].each do |prof|
  BeneficiaryProfessional.find_or_create_by!(beneficiary: beneficiary, professional: prof)
end

Rails.logger.debug 'Usuários de teste criados:'
Rails.logger.debug ' - prof.total@example.com / Senha@123'
Rails.logger.debug ' - secretaria@example.com / Senha@123'
Rails.logger.debug ' - prof.sem.acesso@example.com / Senha@123'
Rails.logger.debug { "Beneficiário para testes: ##{beneficiary.id} - #{beneficiary.name}" }
