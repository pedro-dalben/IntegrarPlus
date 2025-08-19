puts "🧪 Testando Integração Profissional ↔ Usuário..."

# Criar um profissional de teste
professional = Professional.create!(
  full_name: 'João Silva Teste',
  email: 'joao.teste@example.com',
  cpf: '12345678901',
  phone: '(11) 99999-9999',
  workload_minutes: 480,
  active: true,
  password: '123456',
  password_confirmation: '123456'
)

puts "✅ Profissional criado: #{professional.full_name}"

# Verificar se o usuário foi criado automaticamente
if professional.user
  puts "✅ Usuário criado automaticamente: #{professional.user.email}"
  puts "🔐 Senha: #{professional.password}"
  
  # Verificar se o convite foi criado
  if professional.user.invites.any?
    invite = professional.user.latest_invite
    puts "✅ Convite criado: #{invite.token}"
    puts "🔗 URL do convite: #{invite.invite_url}"
    puts "⏰ Expira em: #{invite.expires_at}"
  else
    puts "❌ Nenhum convite criado"
  end
else
  puts "❌ Usuário não foi criado automaticamente"
end

# Testar criação manual de usuário
professional2 = Professional.create!(
  full_name: 'Maria Santos Teste',
  email: 'maria.teste@example.com',
  cpf: '98765432109',
  phone: '(11) 88888-8888',
  workload_minutes: 480,
  active: false
)

puts "\n✅ Profissional inativo criado: #{professional2.full_name}"

# Criar usuário manualmente
if !professional2.user
  professional2.ensure_user_exists!
  puts "✅ Usuário criado manualmente: #{professional2.user.email}"
  
  # Verificar se o convite foi criado (deve ser nil pois está inativo)
  if professional2.user.invites.any?
    puts "⚠️ Convite criado mesmo sendo inativo"
  else
    puts "✅ Nenhum convite criado (profissional inativo)"
  end
end

puts "\n📊 Resumo do Teste:"
puts "👤 Profissionais criados: #{Professional.count}"
puts "👤 Usuários criados: #{User.count}"
puts "🔗 Convites criados: #{Invite.count}"

puts "\n✅ Teste de integração concluído!"
