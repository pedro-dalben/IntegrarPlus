# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "contato@integrarplus.com.br")
  layout 'mailer'
end
