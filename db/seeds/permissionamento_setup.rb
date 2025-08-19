puts "🔧 Configurando Sistema de Permissionamento..."

# Criar permissões se não existirem
permissions_data = [
  { key: 'dashboard.view', description: 'Visualizar dashboard' },
  { key: 'professionals.index', description: 'Listar profissionais' },
  { key: 'professionals.show', description: 'Ver detalhes de profissional' },
  { key: 'professionals.new', description: 'Criar novo profissional' },
  { key: 'professionals.create', description: 'Salvar profissional' },
  { key: 'professionals.edit', description: 'Editar profissional' },
  { key: 'professionals.update', description: 'Atualizar profissional' },
  { key: 'professionals.destroy', description: 'Excluir profissional' },
  { key: 'users.index', description: 'Listar usuários' },
  { key: 'users.show', description: 'Ver detalhes de usuário' },
  { key: 'users.new', description: 'Criar novo usuário' },
  { key: 'users.create', description: 'Salvar usuário' },
  { key: 'users.edit', description: 'Editar usuário' },
  { key: 'users.update', description: 'Atualizar usuário' },
  { key: 'users.destroy', description: 'Excluir usuário' },
  { key: 'users.activate', description: 'Ativar usuário' },
  { key: 'users.deactivate', description: 'Desativar usuário' },
  { key: 'invites.index', description: 'Listar convites' },
  { key: 'invites.show', description: 'Ver detalhes de convite' },
  { key: 'invites.create', description: 'Criar convite' },
  { key: 'invites.update', description: 'Atualizar convite' },
  { key: 'invites.destroy', description: 'Excluir convite' },
  { key: 'invites.resend', description: 'Reenviar convite' },
  { key: 'groups.manage', description: 'Gerenciar grupos' },
  { key: 'settings.read', description: 'Ler configurações' },
  { key: 'settings.write', description: 'Editar configurações' },
  { key: 'reports.view', description: 'Visualizar relatórios' },
  { key: 'reports.generate', description: 'Gerar relatórios' }
]

permissions_data.each do |perm_data|
  Permission.find_or_create_by(key: perm_data[:key]) do |permission|
    permission.description = perm_data[:description]
  end
end

puts "✅ Permissões configuradas"

# Configurar permissões por grupo
admin_group = Group.find_by(name: 'Admin')
if admin_group
  # Admin tem todas as permissões
  Permission.all.each do |permission|
    admin_group.add_permission(permission.key) unless admin_group.has_permission?(permission.key)
  end
  puts "✅ Permissões do grupo Admin configuradas"
end

prof_group = Group.find_by(name: 'Profissionais')
if prof_group
  # Profissionais têm permissões básicas
  basic_permissions = [
    'dashboard.view',
    'professionals.index',
    'professionals.show'
  ]
  
  basic_permissions.each do |perm_key|
    prof_group.add_permission(perm_key) unless prof_group.has_permission?(perm_key)
  end
  puts "✅ Permissões do grupo Profissionais configuradas"
end

recepcao_group = Group.find_by(name: 'Recepção')
if recepcao_group
  # Recepção pode criar profissionais
  recepcao_permissions = [
    'dashboard.view',
    'professionals.index',
    'professionals.show',
    'professionals.new',
    'professionals.create'
  ]
  
  recepcao_permissions.each do |perm_key|
    recepcao_group.add_permission(perm_key) unless recepcao_group.has_permission?(perm_key)
  end
  puts "✅ Permissões do grupo Recepção configuradas"
end

clinico_group = Group.find_by(name: 'Clínico')
if clinico_group
  # Clínicos podem ver e editar profissionais
  clinico_permissions = [
    'dashboard.view',
    'professionals.index',
    'professionals.show',
    'professionals.edit',
    'professionals.update'
  ]
  
  clinico_permissions.each do |perm_key|
    clinico_group.add_permission(perm_key) unless clinico_group.has_permission?(perm_key)
  end
  puts "✅ Permissões do grupo Clínico configuradas"
end

puts "\n📊 Resumo da Configuração:"
puts "🔐 Permissões criadas: #{Permission.count}"
puts "👥 Grupos configurados: #{Group.count}"

Group.all.each do |group|
  puts "  - #{group.name}: #{group.permissions.count} permissões"
end

puts "\n✅ Configuração do sistema de permissionamento concluída!"
