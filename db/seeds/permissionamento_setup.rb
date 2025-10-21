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
  { key: 'organograms.import', description: 'Importar dados para organogramas' },
  { key: 'documents.access', description: 'Acessar área de documentos' },
  { key: 'documents.create', description: 'Criar novos documentos' },
  { key: 'documents.view_released', description: 'Ver documentos liberados' },
  { key: 'documents.manage_permissions', description: 'Gerenciar permissões de documentos' },
  { key: 'documents.assign_responsibles', description: 'Atribuir responsáveis a documentos' },
  { key: 'documents.release', description: 'Liberar documentos' },
  { key: 'specialities.index', description: 'Listar especialidades' },
  { key: 'specialities.manage', description: 'Gerenciar especialidades' },
  { key: 'specializations.index', description: 'Listar especializações' },
  { key: 'specializations.manage', description: 'Gerenciar especializações' },
  { key: 'contract_types.index', description: 'Listar tipos de contrato' },
  { key: 'contract_types.manage', description: 'Gerenciar tipos de contrato' },
  { key: 'agendas.read', description: 'Visualizar agendas' },
  { key: 'agendas.create', description: 'Criar agendas' },
  { key: 'agendas.update', description: 'Editar agendas' },
  { key: 'agendas.destroy', description: 'Excluir agendas' },
  { key: 'agendas.archive', description: 'Arquivar agendas' },
  { key: 'agendas.activate', description: 'Ativar agendas' },
  { key: 'agendas.duplicate', description: 'Duplicar agendas' },
  { key: 'external_users.index', description: 'Listar operadoras' },
  { key: 'external_users.show', description: 'Ver detalhes de operadora' },
  { key: 'external_users.new', description: 'Criar nova operadora' },
  { key: 'external_users.create', description: 'Salvar operadora' },
  { key: 'external_users.edit', description: 'Editar operadora' },
  { key: 'external_users.update', description: 'Atualizar operadora' },
  { key: 'external_users.destroy', description: 'Excluir operadora' },
  # Permissões de Beneficiários
  { key: 'beneficiaries.index', description: 'Listar beneficiários' },
  { key: 'beneficiaries.show', description: 'Ver detalhes do beneficiário' },
  { key: 'beneficiaries.new', description: 'Criar novo beneficiário (formulário)' },
  { key: 'beneficiaries.create', description: 'Criar novos beneficiários' },
  { key: 'beneficiaries.edit', description: 'Editar beneficiários' },
  { key: 'beneficiaries.update', description: 'Atualizar beneficiários' },
  { key: 'beneficiaries.destroy', description: 'Excluir beneficiários' },
  { key: 'beneficiaries.search', description: 'Buscar beneficiários' },
  # Permissões de Anamnese
  { key: 'anamneses.index', description: 'Listar anamneses' },
  { key: 'anamneses.show', description: 'Ver detalhes da anamnese' },
  { key: 'anamneses.new', description: 'Criar nova anamnese (formulário)' },
  { key: 'anamneses.create', description: 'Criar anamnese' },
  { key: 'anamneses.edit', description: 'Editar anamnese' },
  { key: 'anamneses.update', description: 'Atualizar anamnese' },
  { key: 'anamneses.complete', description: 'Concluir anamnese' },
  { key: 'anamneses.view_all', description: 'Ver todas as anamneses (não apenas próprias)' },
  { key: 'anamneses.today', description: 'Ver anamneses de hoje' },
  { key: 'anamneses.by_professional', description: 'Ver anamneses por profissional' }
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
  basic_permissions = [
    'dashboard.view',
    'professionals.index',
    'professionals.show',
    'beneficiaries.index',
    'beneficiaries.show',
    'beneficiaries.search',
    'anamneses.index',
    'anamneses.show',
    'anamneses.new',
    'anamneses.create',
    'anamneses.edit',
    'anamneses.update',
    'anamneses.complete',
    'anamneses.today',
    'anamneses.by_professional'
  ]

  basic_permissions.each do |perm_key|
    prof_group.add_permission(perm_key) unless prof_group.has_permission?(perm_key)
  end
  Rails.logger.debug '✅ Permissões do grupo Profissionais configuradas'
end

recepcao_group = Group.find_by(name: 'Recepção')
if recepcao_group
  recepcao_permissions = [
    'dashboard.view',
    'professionals.index',
    'professionals.show',
    'professionals.new',
    'professionals.create',
    'portal_intakes.index',
    'portal_intakes.show',
    'portal_intakes.schedule_anamnesis',
    'portal_intakes.update',
    'agendas.read',
    'agendas.create',
    'agendas.update',
    'beneficiaries.index',
    'beneficiaries.show',
    'beneficiaries.new',
    'beneficiaries.create',
    'beneficiaries.edit',
    'beneficiaries.update',
    'beneficiaries.search',
    'anamneses.index',
    'anamneses.show',
    'anamneses.new',
    'anamneses.create',
    'anamneses.edit',
    'anamneses.update',
    'anamneses.view_all',
    'anamneses.today',
    'anamneses.by_professional'
  ]

  recepcao_permissions.each do |perm_key|
    recepcao_group.add_permission(perm_key) unless recepcao_group.has_permission?(perm_key)
  end
  Rails.logger.debug '✅ Permissões do grupo Recepção configuradas'
end

clinico_group = Group.find_by(name: 'Clínico')
if clinico_group
  clinico_permissions = [
    'dashboard.view',
    'professionals.index',
    'professionals.show',
    'professionals.edit',
    'professionals.update',
    'agendas.read',
    'beneficiaries.index',
    'beneficiaries.show',
    'beneficiaries.new',
    'beneficiaries.create',
    'beneficiaries.edit',
    'beneficiaries.update',
    'beneficiaries.search',
    'anamneses.index',
    'anamneses.show',
    'anamneses.new',
    'anamneses.create',
    'anamneses.edit',
    'anamneses.update',
    'anamneses.complete',
    'anamneses.view_all',
    'anamneses.today',
    'anamneses.by_professional'
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
