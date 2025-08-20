class InvitesController < ApplicationController
  layout 'admin'
  
  before_action :set_invite, only: [:show, :accept]
  before_action :check_invite_validity, only: [:show, :accept]

  def show
  end

  def accept
    if @invite.confirmed?
      redirect_to new_user_session_path, alert: 'Este convite já foi confirmado.'
      return
    end

    if @invite.max_attempts_reached?
      redirect_to new_user_session_path, alert: 'Número máximo de tentativas excedido.'
      return
    end

    @invite.increment_attempts!

    if params[:password].present? && params[:password_confirmation].present?
      if params[:password] == params[:password_confirmation]
        @invite.user.update!(password: params[:password])
        @invite.confirm!
        
        sign_in(@invite.user)
        redirect_to admin_path, notice: 'Conta ativada com sucesso!'
      else
        flash.now[:alert] = 'As senhas não coincidem.'
        render :show
      end
    else
      flash.now[:alert] = 'Por favor, defina uma senha.'
      render :show
    end
  end

  private

  def set_invite
    @invite = Invite.find_by!(token: params[:token])
  end

  def check_invite_validity
    if @invite.expired?
      redirect_to new_user_session_path, alert: 'Este convite expirou.'
    end
  end
end
