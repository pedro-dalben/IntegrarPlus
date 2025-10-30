# frozen_string_literal: true

Rails.application.configure do
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address: ENV.fetch('OCI_SMTP_HOST', 'smtp.email.sa-saopaulo-1.oci.oraclecloud.com'),
    port: Integer(ENV.fetch('OCI_SMTP_PORT', '587')),
    domain: ENV.fetch('MAIL_DOMAIN', 'integrarplus.com.br'),
    user_name: ENV.fetch('OCI_SMTP_USERNAME'),
    password: ENV.fetch('OCI_SMTP_PASSWORD'),
    authentication: :plain, # servidor anuncia AUTH PLAIN
    enable_starttls_auto: true,
    openssl_verify_mode: 'peer'
  }

  # URLs geradas em e-mails (Devise, links de confirmação, etc.)
  host      = ENV.fetch('APP_HOST', 'localhost:3001')
  protocol  = ENV.fetch('APP_PROTOCOL', 'http')
  config.action_mailer.default_url_options = { host: host, protocol: protocol }
  config.action_mailer.asset_host = "#{protocol}://#{host}"
end
