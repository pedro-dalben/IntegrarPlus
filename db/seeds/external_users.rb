# frozen_string_literal: true

puts "Criando usuários externos (operadoras)..."

# Operadora exemplo
external_user = ExternalUser.find_or_create_by(email: 'operadora@exemplo.com') do |user|
  user.name = 'Maria Silva'
  user.company_name = 'Operadora Saúde Exemplo'
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.active = true
end

puts "Usuário externo criado: #{external_user.email} (#{external_user.company_name})"

# Criar algumas solicitações exemplo
5.times do |i|
  service_request = external_user.service_requests.find_or_create_by(
    cpf: "123.456.789-#{i.to_s.rjust(2, '0')}"
  ) do |request|
    request.convenio = "Convênio #{i + 1}"
    request.carteira_codigo = "CART#{(i + 1) * 1000}"
    request.tipo_convenio = ['particular', 'empresarial', 'familiar'].sample
    request.nome = "Beneficiário #{i + 1}"
    request.data_nascimento = (20..60).to_a.sample.years.ago.to_date
    request.endereco = "Rua Exemplo #{i + 1}, #{rand(100..999)}, Centro, Cidade - UF, CEP #{rand(10000..99999)}-#{rand(100..999)}"
    request.responsavel = i.even? ? "Responsável #{i + 1}" : nil
    request.data_encaminhamento = rand(30.days).seconds.ago.to_date
    request.status = i.even? ? 'aguardando' : 'processado'
  end

  # Adicionar encaminhamentos para cada solicitação
  if service_request.service_request_referrals.empty?
    rand(1..3).times do |j|
      service_request.service_request_referrals.create!(
        cid: "#{['F', 'G', 'H', 'M'].sample}#{rand(10..99)}.#{rand(0..9)}",
        encaminhado_para: ServiceRequestReferral::ENCAMINHAMENTO_OPTIONS.sample,
        medico: "Dr. Exemplo #{j + 1}",
        descricao: "Descrição do encaminhamento #{j + 1} para o beneficiário #{service_request.nome}"
      )
    end
  end

  puts "Solicitação criada: #{service_request.nome} (#{service_request.status})"
end

puts "Seeds de usuários externos concluídas!"
