# frozen_string_literal: true

class DeviseMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  # Sobrescrever o método default_url_options para usar as variáveis de ambiente
  def default_url_options
    {
      host: ENV.fetch("APP_HOST", "localhost:3001"),
      protocol: ENV.fetch("APP_PROTOCOL", "http")
    }
  end

  # Sobrescrever o método reset_password_instructions para garantir que funcione
  def reset_password_instructions(record, token, opts = {})
    @token = token
    devise_mail(record, :reset_password_instructions, opts)
  end
end
