# frozen_string_literal: true

Rails.logger.debug '🔐 Configurando Permissões de Abas de Beneficiário...'

beneficiary_tabs_permissions = [
  { key: 'beneficiary.tabs.anamnesis.show', description: 'Visualizar aba Anamnese do beneficiário' },
  { key: 'beneficiary.tabs.anamnesis.edit', description: 'Editar dados na aba Anamnese do beneficiário' },
  { key: 'beneficiary.tabs.anamnesis.destroy', description: 'Excluir dados na aba Anamnese do beneficiário' },
  { key: 'beneficiary.tabs.professionals.show', description: 'Visualizar aba Profissionais do beneficiário' },
  { key: 'beneficiary.tabs.professionals.edit', description: 'Editar profissionais relacionados ao beneficiário' },
  { key: 'beneficiary.tabs.professionals.destroy', description: 'Remover profissionais relacionados ao beneficiário' },
  { key: 'beneficiary.tabs.chat.show', description: 'Acessar chat do beneficiário' },
  { key: 'beneficiary.tabs.chat.edit', description: 'Enviar mensagens no chat do beneficiário' },
  { key: 'beneficiary.tabs.tickets.show', description: 'Visualizar aba Chamados do beneficiário' },
  { key: 'beneficiary.tabs.tickets.edit', description: 'Criar e editar chamados do beneficiário' },
  { key: 'beneficiary.tabs.tickets.destroy', description: 'Excluir chamados do beneficiário' },
  { key: 'beneficiary.tabs.secretary_access', description: 'Acesso da secretaria ao chat e chamados do beneficiário' },
  { key: 'beneficiary_chat_messages.create', description: 'Criar mensagens no chat do beneficiário' },
  { key: 'beneficiary_tickets.create', description: 'Criar chamados do beneficiário' },
  { key: 'beneficiary_tickets.update', description: 'Atualizar chamados do beneficiário' },
  { key: 'beneficiary_tickets.destroy', description: 'Excluir chamados do beneficiário' }
]

beneficiary_tabs_permissions.each do |perm_data|
  Permission.find_or_create_by(key: perm_data[:key]) do |permission|
    permission.description = perm_data[:description]
  end
end

Rails.logger.debug '✅ Permissões de abas de beneficiário criadas'

admin_group = Group.find_by(name: 'Administradores') || Group.admin.first
if admin_group
  all_permissions = beneficiary_tabs_permissions.pluck(:key) + [
    'beneficiary_chat_messages.create',
    'beneficiary_tickets.create',
    'beneficiary_tickets.update',
    'beneficiary_tickets.destroy'
  ]
  all_permissions.each do |perm_key|
    admin_group.add_permission(perm_key) unless admin_group.has_permission?(perm_key)
  end
  Rails.logger.debug '✅ Permissões de abas atribuídas ao grupo Administradores'
end

profissionais_group = Group.find_by(name: 'Profissionais')
if profissionais_group
  prof_permissions = [
    'beneficiary.tabs.anamnesis.show',
    'beneficiary.tabs.anamnesis.edit',
    'beneficiary.tabs.professionals.show',
    'beneficiary.tabs.professionals.edit',
    'beneficiary.tabs.chat.show',
    'beneficiary.tabs.chat.edit',
    'beneficiary.tabs.tickets.show',
    'beneficiary.tabs.tickets.edit',
    'beneficiary_chat_messages.create',
    'beneficiary_tickets.create',
    'beneficiary_tickets.update'
  ]

  prof_permissions.each do |perm_key|
    profissionais_group.add_permission(perm_key) unless profissionais_group.has_permission?(perm_key)
  end
  Rails.logger.debug '✅ Permissões de abas atribuídas ao grupo Profissionais'
end

secretarias_group = Group.find_by(name: 'Secretárias')
if secretarias_group
  secretaria_permissions = [
    'beneficiary.tabs.chat.show',
    'beneficiary.tabs.chat.edit',
    'beneficiary.tabs.tickets.show',
    'beneficiary.tabs.tickets.edit',
    'beneficiary.tabs.secretary_access',
    'beneficiary_chat_messages.create',
    'beneficiary_tickets.create',
    'beneficiary_tickets.update',
    'beneficiary_tickets.destroy'
  ]

  secretaria_permissions.each do |perm_key|
    secretarias_group.add_permission(perm_key) unless secretarias_group.has_permission?(perm_key)
  end
  Rails.logger.debug '✅ Permissões de abas atribuídas ao grupo Secretárias'
end

Rails.logger.debug "\n✅ Configuração de permissões de abas de beneficiário concluída!"
