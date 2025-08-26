# frozen_string_literal: true

class InvitesController < ApplicationController

  before_action :set_invite, only: %i[show accept]
  before_action :check_invite_validity, only: %i[show accept]

  def show; end

  def accept
    Rails.logger.info "Parâmetros recebidos: #{params.inspect}"

    if @invite.confirmed?
      redirect_to new_user_session_path, alert: 'Este convite já foi confirmado.'
      return
    end

    if @invite.max_attempts_reached?
      redirect_to new_user_session_path, alert: 'Número máximo de tentativas excedido.'
      return
    end

    if request.get?
      redirect_to invite_path(@invite.token)
      return
    end

    if params[:password].present? && params[:password_confirmation].present?
      @invite.increment_attempts!

      if params[:password] == params[:password_confirmation]
        begin
          user = @invite.user
          user.password = params[:password]
          user.password_confirmation = params[:password_confirmation]

          if user.save
            Rails.logger.info "Usuário salvo com sucesso: #{user.email}"
            @invite.confirm!
            Rails.logger.info "Convite confirmado: #{@invite.token}"
            sign_in(user)
            Rails.logger.info "Usuário logado: #{user.email}"
            redirect_to root_path, notice: 'Conta ativada com sucesso!'
          else
            Rails.logger.error "Erro de validação: #{user.errors.full_messages.join(', ')}"
            flash.now[:alert] = "Erro de validação: #{user.errors.full_messages.join(', ')}"
            render :show
          end
        rescue => e
          Rails.logger.error "Erro ao ativar conta: #{e.message}"
          flash.now[:alert] = 'Erro ao ativar conta. Tente novamente.'
          render :show
        end
      else
        flash.now[:alert] = 'As senhas não coincidem.'
        render :show
      end
    else
      redirect_to invite_path(@invite.token)
    end
  end

  private

  def set_invite
    @invite = Invite.find_by!(token: params[:token])
  end

  def check_invite_validity
    return unless @invite.expired?

    redirect_to new_user_session_path, alert: 'Este convite expirou.'
  end
end
