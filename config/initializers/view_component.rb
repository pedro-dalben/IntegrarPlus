# frozen_string_literal: true

Rails.application.config.view_component.preview_paths << Rails.root.join('spec/components/previews').to_s
Rails.application.config.view_component.preview_route = '/previews'
Rails.application.config.view_component.show_previews = Rails.env.development?
