class SystemMailer < ApplicationMailer
  def ping(to = 'seuemail@gmail.com')
    mail(to: to, subject: 'Teste Oracle Email Delivery', body: 'Tudo certo por aqui! ✅')
  end
end
