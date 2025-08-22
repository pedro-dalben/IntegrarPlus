module Admin
  class InvitesController < BaseController
    before_action :set_user, only: %i[index create]
    before_action :set_invite, only: %i[show destroy resend]

    def index
      @invites = @user.invites.order(created_at: :desc)
    end

    def show; end

    def create
      @invite = @user.invites.build

      if @invite.save
        # Enviar e-mail de convite
        begin
          InviteMailer.invite_email(@invite).deliver_now
          redirect_to admin_user_invites_path(@user), notice: t('admin.invites.messages.created')
        rescue StandardError => e
          redirect_to admin_user_invites_path(@user), alert: t('admin.invites.messages.email_error', error: e.message)
        end
      else
        redirect_to admin_user_path(@user), alert: t('admin.users.errors.invite_error')
      end
    end

    def destroy
      @invite.destroy
      redirect_to admin_user_invites_path(@invite.user), notice: t('admin.invites.messages.deleted')
    end

    def resend
      if @invite.expired?
        @invite.update!(expires_at: 7.days.from_now, attempts_count: 0)
        redirect_to admin_user_invites_path(@invite.user), notice: t('admin.invites.messages.renewed')
      else
        redirect_to admin_user_invites_path(@invite.user), alert: t('admin.invites.messages.not_expired')
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
