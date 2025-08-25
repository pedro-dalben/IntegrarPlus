# frozen_string_literal: true

class InviteMailer < ApplicationMailer
  def invite_email(invite)
    @invite = invite
    @user = invite.user
    @professional = @user.professional

    # Preload specialities se professional existir
    @professional = Professional.includes(:specialities).find(@professional.id) if @professional

    mail(
      to: @user.email,
      subject: 'Convite para acessar o sistema IntegrarPlus'
    )
  end
end
