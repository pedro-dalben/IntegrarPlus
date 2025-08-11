source "https://rubygems.org"

gem "rails", "~> 8.0.2"
gem "pg", ">= 1.1"
gem "puma", ">= 5.0"
gem "propshaft"
gem "dotenv-rails"
gem "bootsnap", require: false

gem "vite_rails"

gem "turbo-rails"
gem "stimulus-rails"

gem "devise", "~> 4.9"
gem "pundit"

gem "meilisearch-rails"

gem "solid_queue"
gem "solid_cache"
gem "solid_cable"

gem "sidekiq"

gem "httparty", "~> 0.23.1"
gem "faraday", "~> 2.13"

gem "image_processing", "~> 1.13"
gem "paper_trail"

gem "simple_form"
gem "simple_form-tailwind"
gem "jbuilder"

gem "prawn"
gem "prawn-table"

gem "kamal", require: false
gem "thruster", require: false

group :development do
  gem "web-console"
  gem "hotwire-spark"
  gem "foreman", "~> 0.88.1"
end

group :development, :test do
  gem "debug", require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails", "~> 8.0"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

gem "tzinfo-data", platforms: %i[windows jruby]
