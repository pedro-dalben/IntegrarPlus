puts '🧪 Testando Sistema de Permissionamento...'

# Testar se os modelos estão funcionando
puts '✅ Modelos carregados com sucesso'

# Testar permissões existentes
permissions = Permission.all
puts "📋 Permissões encontradas: #{permissions.count}"

# Testar grupos existentes
groups = Group.all
puts "👥 Grupos encontrados: #{groups.count}"

# Testar se o grupo Admin existe
admin_group = Group.find_by(name: 'Admin')
if admin_group
  puts '✅ Grupo Admin encontrado'
  puts "🔐 Permissões do grupo Admin: #{admin_group.permissions.pluck(:key).join(', ')}"
else
  puts '❌ Grupo Admin não encontrado'
end

# Testar se o grupo Profissionais existe
prof_group = Group.find_by(name: 'Profissionais')
if prof_group
  puts '✅ Grupo Profissionais encontrado'
  puts "🔐 Permissões do grupo Profissionais: #{prof_group.permissions.pluck(:key).join(', ')}"
else
  puts '❌ Grupo Profissionais não encontrado'
end

# Testar criação de convite
test_user = User.first
if test_user
  invite = test_user.invites.create!
  puts '✅ Convite criado com sucesso'
  puts "🔗 Token: #{invite.token}"
  puts "⏰ Expira em: #{invite.expires_at}"
  puts "🔗 URL: #{invite.invite_url}"
else
  puts '❌ Nenhum usuário encontrado para testar convite'
end

puts "\n✅ Teste do sistema de permissionamento concluído!"
