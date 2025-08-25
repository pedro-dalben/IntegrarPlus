# frozen_string_literal: true

Rails.logger.debug '🧪 Testando Sistema de Permissionamento...'

# Testar se os modelos estão funcionando
Rails.logger.debug '✅ Modelos carregados com sucesso'

# Testar permissões existentes
permissions = Permission.all
Rails.logger.debug { "📋 Permissões encontradas: #{permissions.count}" }

# Testar grupos existentes
groups = Group.all
Rails.logger.debug { "👥 Grupos encontrados: #{groups.count}" }

# Testar se o grupo Admin existe
admin_group = Group.find_by(name: 'Admin')
if admin_group
  Rails.logger.debug '✅ Grupo Admin encontrado'
  Rails.logger.debug { "🔐 Permissões do grupo Admin: #{admin_group.permissions.pluck(:key).join(', ')}" }
else
  Rails.logger.debug '❌ Grupo Admin não encontrado'
end

# Testar se o grupo Profissionais existe
prof_group = Group.find_by(name: 'Profissionais')
if prof_group
  Rails.logger.debug '✅ Grupo Profissionais encontrado'
  Rails.logger.debug { "🔐 Permissões do grupo Profissionais: #{prof_group.permissions.pluck(:key).join(', ')}" }
else
  Rails.logger.debug '❌ Grupo Profissionais não encontrado'
end

# Testar criação de convite
test_user = User.first
if test_user
  invite = test_user.invites.create!
  Rails.logger.debug '✅ Convite criado com sucesso'
  Rails.logger.debug { "🔗 Token: #{invite.token}" }
  Rails.logger.debug { "⏰ Expira em: #{invite.expires_at}" }
  Rails.logger.debug { "🔗 URL: #{invite.invite_url}" }
else
  Rails.logger.debug '❌ Nenhum usuário encontrado para testar convite'
end

Rails.logger.debug "\n✅ Teste do sistema de permissionamento concluído!"
