# frozen_string_literal: true

def gerar_cpf_valido
  cpf_base = Array.new(9) { rand(0..9) }

  primeiro_digito = calcular_digito_verificador(cpf_base, 10)
  cpf_base << primeiro_digito

  segundo_digito = calcular_digito_verificador(cpf_base, 11)
  cpf_base << segundo_digito

  format('%03d.%03d.%03d-%02d',
         cpf_base[0..2].join.to_i,
         cpf_base[3..5].join.to_i,
         cpf_base[6..8].join.to_i,
         cpf_base[9..10].join.to_i)
end

def calcular_digito_verificador(cpf_array, peso_inicial)
  soma = cpf_array.each_with_index.sum do |digito, index|
    digito * (peso_inicial - index)
  end

  resto = soma % 11
  resto < 2 ? 0 : 11 - resto
end

Rails.logger.debug '🏥 Criando entradas no Portal de Operadoras...'

operator = ExternalUser.find_by(email: 'unimed@integrarplus.com')

unless operator
  Rails.logger.debug '❌ Operadora não encontrada. Criando operadora Unimed...'
  operator = ExternalUser.create!(
    company_name: 'Unimed',
    email: 'unimed@integrarplus.com',
    password: 'Unimed2025!',
    password_confirmation: 'Unimed2025!',
    active: true
  )
end

nomes = [
  'Maria Silva Santos',
  'João Pedro Oliveira',
  'Ana Carolina Costa',
  'Carlos Eduardo Lima',
  'Juliana Fernandes Souza',
  'Rafael Alves Pereira',
  'Beatriz Rodrigues Martins',
  'Lucas Gabriel Ferreira',
  'Mariana Cristina Almeida',
  'Felipe Henrique Barbosa',
  'Patricia Santos Ribeiro',
  'Bruno Costa Carvalho',
  'Camila Oliveira Dias',
  'Diego Fernandes Rocha',
  'Larissa Alves Monteiro'
]

planos = [
  'Unimed Premium',
  'Unimed Empresarial',
  'Unimed Individual',
  'Amil Saúde',
  'Bradesco Saúde Top',
  'SulAmérica Clássico',
  'NotreDame Intermédica',
  'Porto Seguro Saúde'
]

10.times do |i|
  gerar_cpf_valido
  format('(%02d) %05d-%04d', [11, 21, 31, 41, 51].sample, rand(90_000..99_999), rand(1000..9999))

  status = 'aguardando_anamnese'
  anamnesis_date = rand(1..30).days.from_now

  portal_intake = PortalIntake.create!(
    nome: nomes[i],
    beneficiary_name: nomes[i],
    plan_name: planos.sample,
    card_code: "CARD#{rand(10_000..99_999)}",
    status: status,
    anamnesis_scheduled_on: anamnesis_date,
    requested_at: rand(1..60).days.ago,
    operator: operator
  )

  Rails.logger.debug do
    "  ✅ Entrada ##{portal_intake.id} - #{portal_intake.beneficiary_name} (#{portal_intake.status_label})"
  end
end

Rails.logger.debug { "\n✨ #{PortalIntake.count} entradas criadas com sucesso!" }
Rails.logger.debug "\n📊 Resumo por status:"
PortalIntake.group(:status).count.each do |status, count|
  label = PortalIntake.new(status: status).status_label
  Rails.logger.debug { "  - #{label}: #{count}" }
end
