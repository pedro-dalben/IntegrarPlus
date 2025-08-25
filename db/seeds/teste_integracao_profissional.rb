# frozen_string_literal: true

Rails.logger.debug '🧪 Testando Integração Profissional ↔ Usuário...'

# Criar um profissional de teste
professional = Professional.create!(
  full_name: 'João Silva Teste Integração Final',
  email: 'joao.integracao.final@example.com',
  cpf: '99988877766',
  phone: '(11) 99999-9999',
  workload_minutes: 480,
  active: true
)

Rails.logger.debug { "✅ Profissional criado: #{professional.full_name}" }

# Criar usuário usando o método que implementamos
professional.ensure_user_exists!

# Verificar se o usuário foi criado
if professional.user
  Rails.logger.debug { "✅ Usuário criado automaticamente: #{professional.user.email}" }

  # Verificar se o convite foi criado
  if professional.user.invites.any?
    invite = professional.user.latest_invite
    Rails.logger.debug { "✅ Convite criado: #{invite.token}" }
    Rails.logger.debug { "🔗 URL do convite: #{invite.invite_url}" }
    Rails.logger.debug { "⏰ Expira em: #{invite.expires_at}" }
  else
    Rails.logger.debug '❌ Nenhum convite criado'
  end
else
  Rails.logger.debug '❌ Usuário não foi criado automaticamente'
end

# Testar criação manual de usuário
professional2 = Professional.create!(
  full_name: 'Maria Santos Teste Integração Final',
  email: 'maria.integracao.final@example.com',
  cpf: '44433322211',
  phone: '(11) 88888-8888',
  workload_minutes: 480,
  active: false
)

Rails.logger.debug { "\n✅ Profissional inativo criado: #{professional2.full_name}" }

# Criar usuário manualmente
unless professional2.user
  professional2.ensure_user_exists!
  Rails.logger.debug { "✅ Usuário criado manualmente: #{professional2.user.email}" }

  # Verificar se o convite foi criado (deve ser nil pois está inativo)
  if professional2.user.invites.any?
    Rails.logger.debug '⚠️ Convite criado mesmo sendo inativo'
  else
    Rails.logger.debug '✅ Nenhum convite criado (profissional inativo)'
  end
end

Rails.logger.debug "\n📊 Resumo do Teste:"
Rails.logger.debug { "👤 Profissionais criados: #{Professional.count}" }
Rails.logger.debug { "👤 Usuários criados: #{User.count}" }
Rails.logger.debug { "🔗 Convites criados: #{Invite.count}" }

Rails.logger.debug "\n✅ Teste de integração concluído!"
