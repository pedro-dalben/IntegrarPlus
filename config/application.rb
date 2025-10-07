require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module IntegrarPlus
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Set the default locale
    config.i18n.default_locale = :'pt-BR'
    config.i18n.available_locales = %i[pt pt-BR en]

    # Set time zone
    config.time_zone = 'America/Sao_Paulo'

    # Active Job adapter
    config.active_job.queue_adapter = :sidekiq

    # Active Storage
    config.active_storage.variant_processor = :mini_magick

    # Action Mailer
    config.action_mailer.default_url_options = { host: ENV.fetch('HOST', 'localhost:3000') }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: ENV.fetch('SMTP_ADDRESS', 'localhost'),
      port: ENV.fetch('SMTP_PORT', 587),
      domain: ENV.fetch('SMTP_DOMAIN', 'localhost'),
      user_name: ENV.fetch('SMTP_USERNAME', ''),
      password: ENV.fetch('SMTP_PASSWORD', ''),
      authentication: ENV.fetch('SMTP_AUTHENTICATION', 'plain'),
      enable_starttls_auto: ENV.fetch('SMTP_ENABLE_STARTTLS_AUTO', true)
    }

    # Logging
    config.log_level = :info
    config.log_formatter = ::Logger::Formatter.new

    # CORS (commented out - requires rack-cors gem)
    # config.middleware.insert_before 0, Rack::Cors do
    #   allow do
    #     origins '*'
    #     resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options, :head]
    #   end
    # end
  end
end
