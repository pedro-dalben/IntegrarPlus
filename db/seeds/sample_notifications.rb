puts 'Criando notificações de exemplo...'

# Buscar o usuário admin
admin_user = User.find_by(email: 'admin@integrarplus.com')

if admin_user
  # Criar notificações de exemplo se não existirem
  sample_notifications = [
    {
      title: 'Bem-vindo ao Integrar Plus!',
      message: 'Sistema inicializado com sucesso. Clique para acessar o dashboard e conhecer o sistema.',
      type: 'agenda_created',
      channel: 'in_app',
      read: false,
      created_at: 2.hours.ago
    },
    {
      title: 'Sistema atualizado',
      message: 'Nova versão disponível com melhorias. Clique para ver as configurações.',
      type: 'agenda_updated',
      channel: 'in_app',
      read: false,
      created_at: 1.hour.ago
    },
    {
      title: 'Lembrete importante',
      message: 'Verifique suas configurações de segurança regularmente.',
      type: 'emergency_alert',
      channel: 'in_app',
      read: false,
      created_at: 3.hours.ago
    },
    {
      title: 'Agenda criada com sucesso',
      message: 'Sua nova agenda foi criada e está ativa no sistema.',
      type: 'agenda_created',
      channel: 'in_app',
      read: true,
      read_at: 1.day.ago,
      created_at: 2.days.ago
    },
    {
      title: 'Relatório semanal disponível',
      message: 'Seu relatório semanal de atividades está pronto para visualização.',
      type: 'weekly_report',
      channel: 'in_app',
      read: true,
      read_at: 2.days.ago,
      created_at: 3.days.ago
    }
  ]

  sample_notifications.each do |notification_attrs|
    existing_notification = admin_user.notifications.find_by(
      title: notification_attrs[:title],
      message: notification_attrs[:message]
    )

    if existing_notification
      puts "⏭️  Notificação já existe: #{notification_attrs[:title]}"
    else
      admin_user.notifications.create!(notification_attrs)
      puts "✅ Notificação criada: #{notification_attrs[:title]}"
    end
  end

  # Criar preferências de notificação para o usuário admin se não existirem
  NotificationPreference.create_default_preferences_for_user(admin_user)
  puts '✅ Preferências de notificação criadas para o usuário admin'

  puts "\n📊 Resumo das notificações:"
  puts "   Total: #{admin_user.notifications.count}"
  puts "   Não lidas: #{admin_user.notifications.unread.count}"
  puts "   Lidas: #{admin_user.notifications.read.count}"

else
  puts '❌ Usuário admin não encontrado. Execute os seeds principais primeiro.'
end

puts 'Notificações de exemplo criadas com sucesso!'
