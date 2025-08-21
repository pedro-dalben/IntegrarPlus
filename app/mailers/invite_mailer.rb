class InviteMailer < ApplicationMailer
  def invite_email(invite)
    @invite = invite
    @user = invite.user
    @professional = @user.professional

    mail(
      to: @user.email,
      subject: 'Convite para acessar o sistema IntegrarPlus'
    )
  end
end
