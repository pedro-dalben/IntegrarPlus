# frozen_string_literal: true

Rails.logger.debug '🔧 Configurando Sistema de Permissionamento...'

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
  { key: 'reports.generate', description: 'Gerar relatórios' },
  { key: 'portal_intakes.index', description: 'Listar entradas do portal' },
  { key: 'portal_intakes.show', description: 'Ver detalhes de entrada do portal' },
  { key: 'portal_intakes.schedule_anamnesis', description: 'Agendar anamnese' },
  { key: 'portal_intakes.update', description: 'Atualizar entrada do portal' },
  { key: 'organograms.index', description: 'Listar organogramas' },
  { key: 'organograms.show', description: 'Visualizar organogramas' },
  { key: 'organograms.create', description: 'Criar organogramas' },
  { key: 'organograms.update', description: 'Editar organogramas' },
  { key: 'organograms.destroy', description: 'Excluir organogramas' },
  { key: 'organograms.editor', description: 'Usar editor de organogramas' },
  { key: 'organograms.publish', description: 'Publicar organogramas' },
  { key: 'organograms.export', description: 'Exportar organogramas' },
  { key: 'organograms.import', description: 'Importar dados para organogramas' }
]

permissions_data.each do |perm_data|
  Permission.find_or_create_by(key: perm_data[:key]) do |permission|
    permission.description = perm_data[:description]
  end
end

Rails.logger.debug '✅ Permissões configuradas'

# Configurar permissões por grupo
admin_group = Group.find_by(name: 'Admin')
if admin_group
  # Admin tem todas as permissões
  Permission.find_each do |permission|
    admin_group.add_permission(permission.key) unless admin_group.has_permission?(permission.key)
  end
  Rails.logger.debug '✅ Permissões do grupo Admin configuradas'
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
  Rails.logger.debug '✅ Permissões do grupo Profissionais configuradas'
end

recepcao_group = Group.find_by(name: 'Recepção')
if recepcao_group
  # Recepção pode criar profissionais e gerenciar entradas do portal
  recepcao_permissions = [
    'dashboard.view',
    'professionals.index',
    'professionals.show',
    'professionals.new',
    'professionals.create',
    'portal_intakes.index',
    'portal_intakes.show',
    'portal_intakes.schedule_anamnesis',
    'portal_intakes.update'
  ]

  recepcao_permissions.each do |perm_key|
    recepcao_group.add_permission(perm_key) unless recepcao_group.has_permission?(perm_key)
  end
  Rails.logger.debug '✅ Permissões do grupo Recepção configuradas'
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
  Rails.logger.debug '✅ Permissões do grupo Clínico configuradas'
end

Rails.logger.debug "\n📊 Resumo da Configuração:"
Rails.logger.debug { "🔐 Permissões criadas: #{Permission.count}" }
Rails.logger.debug { "👥 Grupos configurados: #{Group.count}" }

Group.find_each do |group|
  Rails.logger.debug "  - #{group.name}: #{group.permissions.count} permissões"
end

Rails.logger.debug "\n✅ Configuração do sistema de permissionamento concluída!"
