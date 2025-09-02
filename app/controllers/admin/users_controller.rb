# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[show edit update destroy activate deactivate]
    before_action :ensure_professional_exists, only: %i[activate deactivate]

    def index
      redirect_to admin_professionals_path,
                  notice: t('admin.users.messages.redirect_notice')
    end

    def show
      @invites = @user.invites.includes(:user).order(created_at: :desc)
    end

    def edit; end

    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: t('admin.users.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user.professional&.documents&.exists?
        redirect_to admin_user_path(@user), alert: t('admin.users.messages.cannot_delete_with_documents')
        return
      end

      @user.destroy
      redirect_to admin_professionals_path, notice: t('admin.users.messages.deleted')
    end

    def activate
      toggle_professional_status(true, 'activated')
    end

    def deactivate
      toggle_professional_status(false, 'deactivated')
    end

    def search
      return render json: [] if params[:q].blank?

      users = User.joins(:professional)
                  .where('professionals.full_name ILIKE ?', "%#{sanitize_query(params[:q])}%")
                  .includes(:professional)
                  .limit(10)
                  .map { |user| format_user_for_search(user) }

      render json: users
    end

    private

    def set_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_professionals_path, alert: t('admin.users.messages.not_found')
    end

    def ensure_professional_exists
      return if @user.professional

      redirect_to admin_user_path(@user), alert: t('admin.users.messages.no_professional')
    end

    def toggle_professional_status(active_status, action_key)
      @user.professional.update!(active: active_status)
      redirect_to admin_user_path(@user), notice: t("admin.users.messages.#{action_key}")
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_user_path(@user), alert: t('admin.users.messages.update_failed', error: e.message)
    end

    def sanitize_query(query)
      query.to_s.strip.gsub(/[%_]/, '\\\\\&')
    end

    def format_user_for_search(user)
      {
        id: user.id,
        full_name: user.professional.full_name,
        email: user.email,
        active: user.professional.active?
      }
    end

    def user_params
      params.expect(user: %i[email])
    end
  end
end
