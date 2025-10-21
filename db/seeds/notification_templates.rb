# frozen_string_literal: true

Rails.logger.debug 'Criando templates padrão de notificação...'

NotificationTemplate.create_default_templates

Rails.logger.debug 'Templates de notificação criados com sucesso!'
