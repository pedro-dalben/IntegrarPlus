# frozen_string_literal: true

namespace :emails do
  desc "Diagnóstico de configuração de e-mail e teste com mail-tester"
  task diagnostic: :environment do
    puts "=== Diagnóstico Oracle Email Delivery ==="
    puts

    # Verificar configurações
    puts "📧 Configurações SMTP:"
    puts "  Host: #{ENV['OCI_SMTP_HOST']}"
    puts "  Port: #{ENV['OCI_SMTP_PORT']}"
    puts "  Domain: #{ENV['MAIL_DOMAIN']}"
    puts "  From: #{ENV['MAIL_FROM']}"
    puts "  Username: #{ENV['OCI_SMTP_USERNAME']&.truncate(50)}..."
    puts "  Password: #{'*' * (ENV['OCI_SMTP_PASSWORD']&.length || 0)}"
    puts

    # Verificar URLs
    puts "🌐 URLs da aplicação:"
    puts "  Host: #{ENV['APP_HOST']}"
    puts "  Protocol: #{ENV['APP_PROTOCOL']}"
    puts "  Default URL: #{Rails.application.routes.default_url_options}"
    puts

    # Teste básico
    puts "🧪 Teste básico de envio:"
    test_email = ENV['TEST_EMAIL'] || "test-#{SecureRandom.hex(4)}@mail-tester.com"

    begin
      SystemMailer.ping(test_email).deliver_now
      puts "  ✅ E-mail enviado com sucesso para: #{test_email}"

      if test_email.include?('mail-tester.com')
        puts
        puts "📊 Para verificar a pontuação do e-mail:"
        puts "  1. Acesse: https://www.mail-tester.com/"
        puts "  2. Use o e-mail: #{test_email}"
        puts "  3. Verifique SPF, DKIM e DMARC"
      end

    rescue => e
      puts "  ❌ Erro ao enviar e-mail: #{e.message}"
      puts "  Verifique as credenciais e configurações SMTP"
    end

    puts
    puts "🔍 Instruções de verificação:"
    puts "  • SPF: v=spf1 include:rp.oracleemaildelivery.com -all"
    puts "  • DKIM: integrarplus202508._domainkey → integrarplus202508.dkim.gru1.oracleemaildelivery.com"
    puts "  • DMARC: v=DMARC1; p=quarantine; rua=mailto:postmaster@integrarplus.com.br"
    puts
    puts "Para testar com e-mail específico:"
    puts "  rake emails:diagnostic TEST_EMAIL=seu@email.com"
  end

  desc "Teste rápido de envio de e-mail"
  task :test, [:email] => :environment do |t, args|
    email = args[:email] || ENV['TEST_EMAIL']

    if email.blank?
      puts "❌ Especifique um e-mail: rake emails:test[seu@email.com]"
      exit 1
    end

    begin
      SystemMailer.ping(email).deliver_now
      puts "✅ E-mail de teste enviado para: #{email}"
    rescue => e
      puts "❌ Erro: #{e.message}"
      exit 1
    end
  end
end
