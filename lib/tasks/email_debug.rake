# frozen_string_literal: true

namespace :email do
  desc "Diagnóstico detalhado de problemas de entrega de email"
  task debug: :environment do
    puts "=== DIAGNÓSTICO DETALHADO DE EMAIL ==="
    puts

    # 1. Verificar configurações
    puts "1️⃣ CONFIGURAÇÕES SMTP:"
    smtp_settings = Rails.application.config.action_mailer.smtp_settings
    smtp_settings.each do |key, value|
      if key.to_s.include?('password')
        puts "  #{key}: #{'*' * value.to_s.length}"
      else
        puts "  #{key}: #{value}"
      end
    end
    puts

    # 2. Testar conexão SMTP
    puts "2️⃣ TESTE DE CONEXÃO SMTP:"
    begin
      require 'net/smtp'
      smtp = Net::SMTP.new(smtp_settings[:address], smtp_settings[:port])
      smtp.enable_starttls_auto = smtp_settings[:enable_starttls_auto]
      smtp.start(smtp_settings[:domain], smtp_settings[:user_name], smtp_settings[:password], smtp_settings[:authentication]) do |smtp_conn|
        puts "  ✅ Conexão SMTP estabelecida com sucesso"
      end
    rescue => e
      puts "  ❌ Erro na conexão SMTP: #{e.message}"
    end
    puts

    # 3. Verificar DNS
    puts "3️⃣ VERIFICAÇÃO DNS:"
    domain = ENV['MAIL_DOMAIN']

    begin
      require 'resolv'
      resolver = Resolv::DNS.new

      # SPF
      spf_records = resolver.getresources(domain, Resolv::DNS::Resource::IN::TXT)
      spf_record = spf_records.find { |r| r.data.start_with?('v=spf1') }
      if spf_record
        puts "  ✅ SPF encontrado: #{spf_record.data}"
      else
        puts "  ❌ SPF não encontrado"
      end

      # DKIM
      dkim_domain = "integrarplus202508._domainkey.#{domain}"
      dkim_records = resolver.getresources(dkim_domain, Resolv::DNS::Resource::IN::CNAME)
      if dkim_records.any?
        puts "  ✅ DKIM encontrado: #{dkim_records.first.name}"
      else
        puts "  ❌ DKIM não encontrado"
      end

      # DMARC
      dmarc_domain = "_dmarc.#{domain}"
      dmarc_records = resolver.getresources(dmarc_domain, Resolv::DNS::Resource::IN::TXT)
      dmarc_record = dmarc_records.find { |r| r.data.start_with?('v=DMARC1') }
      if dmarc_record
        puts "  ✅ DMARC encontrado: #{dmarc_record.data}"
      else
        puts "  ❌ DMARC não encontrado"
      end
    rescue => e
      puts "  ❌ Erro na verificação DNS: #{e.message}"
    end
    puts

    # 4. Teste de envio com diferentes destinos
    puts "4️⃣ TESTE DE ENVIO PARA DIFERENTES PROVEDORES:"
    test_emails = [
      'pedrodalbenmorais@gmail.com',
      'test@mail-tester.com',
      'test@10minutemail.com'
    ]

    test_emails.each do |email|
      begin
        SystemMailer.ping(email).deliver_now
        puts "  ✅ Enviado para #{email}"
      rescue => e
        puts "  ❌ Erro ao enviar para #{email}: #{e.message}"
      end
    end
    puts

    # 5. Verificar logs recentes
    puts "5️⃣ LOGS RECENTES DE EMAIL:"
    log_file = Rails.root.join('log', "#{Rails.env}.log")
    if File.exist?(log_file)
      recent_logs = `tail -100 #{log_file} | grep -i -E "(mail|smtp|deliver|sent mail)" | tail -5`
      if recent_logs.present?
        puts recent_logs
      else
        puts "  ℹ️ Nenhum log de email encontrado recentemente"
      end
    end
    puts

    puts "=== POSSÍVEIS CAUSAS PARA EMAILS NÃO CHEGAREM ==="
    puts "1. 📧 Caixa de SPAM - Verifique a pasta de spam/lixo eletrônico"
    puts "2. ⏰ Delay de entrega - Emails podem demorar alguns minutos"
    puts "3. 🔒 Filtros do provedor - Gmail/Outlook podem bloquear emails novos"
    puts "4. 🌡️ Warm-up necessário - Domínio novo precisa de reputação"
    puts "5. 📊 Verificar Oracle Console - Logs de entrega no painel Oracle"
    puts
    puts "=== PRÓXIMOS PASSOS ==="
    puts "1. Verifique SPAM em pedrodalbenmorais@gmail.com"
    puts "2. Acesse Oracle Email Delivery Console para logs"
    puts "3. Teste com mail-tester.com para verificar pontuação"
    puts "4. Aguarde 5-10 minutos para entrega"
  end
end
