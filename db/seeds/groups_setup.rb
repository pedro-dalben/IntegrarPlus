# frozen_string_literal: true

Rails.logger.debug '👥 Configurando Grupos Padrão...'

# Criar grupos padrão
groups_data = [
  {
    name: 'Administradores',
    description: 'Grupo com acesso total ao sistema',
    is_admin: true
  },
  {
    name: 'Médicos',
    description: 'Profissionais médicos com acesso a pacientes e prontuários',
    is_admin: false
  },
  {
    name: 'Secretárias',
    description: 'Equipe administrativa com acesso a agendamentos e cadastros básicos',
    is_admin: false
  },
  {
    name: 'Terapeutas',
    description: 'Profissionais de terapia ocupacional, psicologia e fonoaudiologia',
    is_admin: false
  },
  {
    name: 'Recepção',
    description: 'Equipe de recepção com acesso limitado ao sistema',
    is_admin: false
  }
]

groups_data.each do |group_data|
  Group.find_or_create_by!(name: group_data[:name]) do |group|
    group.description = group_data[:description]
    group.is_admin = group_data[:is_admin]
  end
end

Rails.logger.debug '✅ Grupos padrão configurados'

# Configurar permissões por grupo
admin_group = Group.find_by(name: 'Administradores')
if admin_group
  # Administradores têm todas as permissões
  Permission.find_each do |permission|
    admin_group.add_permission(permission.key) unless admin_group.has_permission?(permission.key)
  end
  Rails.logger.debug '✅ Permissões do grupo Administradores configuradas'
end

medicos_group = Group.find_by(name: 'Médicos')
if medicos_group
  # Médicos podem ver e editar profissionais, ver relatórios
  medicos_permissions = [
    'dashboard.view',
    'professionals.index',
    'professionals.show',
    'professionals.edit',
    'professionals.update',
    'reports.view'
  ]

  medicos_permissions.each do |perm_key|
    medicos_group.add_permission(perm_key) unless medicos_group.has_permission?(perm_key)
  end
  Rails.logger.debug '✅ Permissões do grupo Médicos configuradas'
end

secretarias_group = Group.find_by(name: 'Secretárias')
if secretarias_group
  # Secretárias podem criar e gerenciar profissionais
  secretarias_permissions = [
    'dashboard.view',
    'professionals.index',
    'professionals.show',
    'professionals.new',
    'professionals.create',
    'professionals.edit',
    'professionals.update'
  ]

  secretarias_permissions.each do |perm_key|
    secretarias_group.add_permission(perm_key) unless secretarias_group.has_permission?(perm_key)
  end
  Rails.logger.debug '✅ Permissões do grupo Secretárias configuradas'
end

terapeutas_group = Group.find_by(name: 'Terapeutas')
if terapeutas_group
  # Terapeutas podem ver profissionais e relatórios
  terapeutas_permissions = [
    'dashboard.view',
    'professionals.index',
    'professionals.show',
    'reports.view'
  ]

  terapeutas_permissions.each do |perm_key|
    terapeutas_group.add_permission(perm_key) unless terapeutas_group.has_permission?(perm_key)
  end
  Rails.logger.debug '✅ Permissões do grupo Terapeutas configuradas'
end

recepcao_group = Group.find_by(name: 'Recepção')
if recepcao_group
  # Recepção tem acesso básico
  recepcao_permissions = [
    'dashboard.view',
    'professionals.index',
    'professionals.show'
  ]

  recepcao_permissions.each do |perm_key|
    recepcao_group.add_permission(perm_key) unless recepcao_group.has_permission?(perm_key)
  end
  Rails.logger.debug '✅ Permissões do grupo Recepção configuradas'
end

Rails.logger.debug "\n📊 Resumo da Configuração de Grupos:"
Rails.logger.debug { "👥 Grupos criados: #{Group.count}" }
Rails.logger.debug { "🔐 Total de permissões: #{Permission.count}" }
Rails.logger.debug { "🔗 Relacionamentos grupo-permissão: #{GroupPermission.count}" }
