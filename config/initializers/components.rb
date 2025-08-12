# Ensure app/components is autoloaded and eager loaded in all environments
Rails.application.config.autoload_paths << Rails.root.join("app/components")
Rails.application.config.eager_load_paths << Rails.root.join("app/components")


