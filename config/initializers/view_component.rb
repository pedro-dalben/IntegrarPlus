# frozen_string_literal: true

Rails.application.config.view_component.preview_paths << "#{Rails.root}/spec/components/previews"
Rails.application.config.view_component.preview_route = "/previews"
Rails.application.config.view_component.show_previews = Rails.env.development?
