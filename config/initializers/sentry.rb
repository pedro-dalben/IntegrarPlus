# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN'] || 'https://e2d43c8f49a711ef9088f132e16d6b2a@o4510263217618944.ingest.us.sentry.io/4510263219126272'

  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  config.send_default_pii = true

  config.traces_sample_rate = Rails.env.production? ? 0.25 : 1.0

  config.environment = Rails.env

  config.enabled_environments = %w[production staging]

  config.excluded_exceptions += ['ActionController::RoutingError', 'ActiveRecord::RecordNotFound']
end
