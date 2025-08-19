module Admin
  class InvitesController < BaseController
    before_action :set_user, only: [:index, :create]
    before_action :set_invite, only: [:show, :destroy, :resend]

    def index
      @invites = @user.invites.order(created_at: :desc)
    end

    def show
    end

    def create
      @invite = @user.invites.build
      
      if @invite.save
        redirect_to admin_user_invites_path(@user), notice: 'Convite criado com sucesso.'
      else
        redirect_to admin_user_path(@user), alert: 'Erro ao criar convite.'
      end
    end

    def destroy
      @invite.destroy
      redirect_to admin_user_invites_path(@invite.user), notice: 'Convite removido com sucesso.'
    end

    def resend
      if @invite.expired?
        @invite.update!(expires_at: 7.days.from_now, attempts_count: 0)
        redirect_to admin_user_invites_path(@invite.user), notice: 'Convite renovado com sucesso.'
      else
        redirect_to admin_user_invites_path(@invite.user), alert: 'Convite ainda não expirou.'
      end
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    end

    def set_invite
      @invite = Invite.find(params[:id])
    end
  end
end
