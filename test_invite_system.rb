# frozen_string_literal: true

# Teste do Sistema de Convites
# Execute este arquivo no console do Rails: rails console
# load 'test_invite_system.rb'

puts '=== Teste do Sistema de Convites ==='

# Verificar se os modelos estão carregados
begin
  puts 'Verificando modelos...'
  puts "User: #{User}"
  puts "Professional: #{Professional}"
  puts "Invite: #{Invite}"
  puts '✅ Modelos carregados com sucesso'
rescue StandardError => e
  puts "❌ Erro ao carregar modelos: #{e.message}"
  exit
end

# Verificar rotas
puts "\n=== Verificando Rotas ==="
begin
  routes = Rails.application.routes.routes
  invite_routes = routes.select { |r| r.path.spec.to_s.include?('invite') }

  puts 'Rotas de convite encontradas:'
  invite_routes.each do |route|
    puts "  #{route.verb} #{route.path.spec}"
  end

  # Verificar helpers de rota
  puts "\nHelpers de rota:"
  puts "invite_path: #{Rails.application.routes.url_helpers.respond_to?(:invite_path)}"
  puts "accept_invite_post_path: #{Rails.application.routes.url_helpers.respond_to?(:accept_invite_post_path)}"
rescue StandardError => e
  puts "❌ Erro ao verificar rotas: #{e.message}"
end

# Verificar dados disponíveis
puts "\n=== Verificando Dados Disponíveis ==="

professionals_count = Professional.count
users_count = User.count
invites_count = Invite.count

puts "Profissionais disponíveis: #{professionals_count}"
puts "Usuários disponíveis: #{users_count}"
puts "Convites disponíveis: #{invites_count}"

# Testar criação de profissional com usuário automático
puts "\n=== Testando Criação Automática de Usuário ==="

begin
  # Criar profissional de teste
  test_professional = Professional.new(
    full_name: 'Dr. Teste Convite',
    email: 'teste.convite@exemplo.com',
    cpf: '111.222.333-44',
    active: true
  )

  if test_professional.save
    puts "✅ Profissional criado com sucesso: #{test_professional.full_name}"
    puts "  ID: #{test_professional.id}"
    puts "  Email: #{test_professional.email}"
    puts "  Usuário criado: #{test_professional.user.present?}"

    if test_professional.user
      puts "  Usuário ID: #{test_professional.user.id}"
      puts "  Convites do usuário: #{test_professional.user.invites.count}"

      latest_invite = test_professional.user.latest_invite
      if latest_invite
        puts '  Convite mais recente:'
        puts "    Token: #{latest_invite.token}"
        puts "    Status: #{latest_invite.pending? ? 'Pendente' : 'Confirmado'}"
        puts "    Expira em: #{latest_invite.expires_at}"
        puts "    URL do convite: #{latest_invite.invite_url}"
      end
    end

    # Limpar dados de teste
    test_professional.destroy
    puts '✅ Dados de teste removidos'
  else
    puts '❌ Erro ao criar profissional:'
    puts test_professional.errors.full_messages
  end
rescue StandardError => e
  puts "❌ Erro ao testar criação automática: #{e.message}"
  puts e.backtrace.first(5)
end

# Testar sistema de convites existente
puts "\n=== Testando Sistema de Convites Existente ==="

if invites_count.positive?
  latest_invite = Invite.order(created_at: :desc).first
  puts 'Convite mais recente:'
  puts "  Token: #{latest_invite.token}"
  puts "  Usuário: #{latest_invite.user.email}"
  puts "  Status: #{latest_invite.pending? ? 'Pendente' : 'Confirmado'}"
  puts "  Expira em: #{latest_invite.expires_at}"
  puts "  URL do convite: #{latest_invite.invite_url}"

  # Verificar se a URL é válida
  begin
    url = latest_invite.invite_url
    puts "  URL válida: #{url.present?}"
    puts "  Protocolo: #{url.start_with?('http') ? 'HTTP/HTTPS' : 'Outro'}"
  rescue StandardError => e
    puts "  ❌ Erro na URL: #{e.message}"
  end
else
  puts '⚠️ Nenhum convite encontrado para teste'
end

# Verificar configurações de ambiente
puts "\n=== Verificando Configurações de Ambiente ==="

puts "APP_HOST: #{ENV['APP_HOST'] || 'Não definido'}"
puts "APP_PROTOCOL: #{ENV['APP_PROTOCOL'] || 'Não definido'}"
puts "RAILS_ENV: #{Rails.env}"
puts "Default URL Options: #{Rails.application.routes.default_url_options}"

puts "\n=== Teste Concluído ==="
puts 'Verifique os logs do Rails para mais detalhes sobre o sistema de convites.'
