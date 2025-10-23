# frozen_string_literal: true

module Admin
  class ExternalUsersController < BaseController
    before_action :set_external_user, only: %i[show edit update destroy activate deactivate]

    def index
      @external_users = policy_scope(ExternalUser, policy_scope_class: Admin::ExternalUserPolicy::Scope)
                        .includes(:portal_intakes)
                        .order(:company_name, :name)

      @external_users = apply_filters(@external_users)
      @pagy, @external_users = pagy(@external_users, items: 20)

      respond_to do |format|
        format.html
        format.json { render json: { results: @external_users, count: @pagy.count } }
      end
    end

    def show
      authorize @external_user, policy_class: Admin::ExternalUserPolicy
      @portal_intakes = @external_user.portal_intakes.includes(:journey_events)
                                      .recent
                                      .limit(10)
    end

    def new
      @external_user = ExternalUser.new
      authorize @external_user, policy_class: Admin::ExternalUserPolicy
    end

    def edit; end

    def create
      @external_user = ExternalUser.new(external_user_params)
      authorize @external_user, policy_class: Admin::ExternalUserPolicy

      if @external_user.save
        redirect_to admin_external_user_path(@external_user),
                    notice: t('admin.external_users.messages.created')
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @external_user, policy_class: Admin::ExternalUserPolicy
      if @external_user.update(sanitized_external_user_params)
        redirect_to admin_external_user_path(@external_user),
                    notice: t('admin.external_users.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @external_user, policy_class: Admin::ExternalUserPolicy
      if @external_user.portal_intakes.exists?
        redirect_to admin_external_user_path(@external_user),
                    alert: t('admin.external_users.messages.cannot_delete_with_intakes')
        return
      end

      @external_user.destroy
      redirect_to admin_external_users_path,
                  notice: t('admin.external_users.messages.deleted')
    end

    def activate
      authorize @external_user, :activate?, policy_class: Admin::ExternalUserPolicy
      @external_user.update!(active: true)
      redirect_to admin_external_user_path(@external_user),
                  notice: t('admin.external_users.messages.activated')
    end

    def deactivate
      authorize @external_user, :deactivate?, policy_class: Admin::ExternalUserPolicy
      @external_user.update!(active: false)
      redirect_to admin_external_user_path(@external_user),
                  notice: t('admin.external_users.messages.deactivated')
    end

    def search
      return render json: [] if params[:q].blank?

      external_users = ExternalUser.where(
        'name ILIKE ? OR company_name ILIKE ? OR email ILIKE ?',
        "%#{sanitize_query(params[:q])}%",
        "%#{sanitize_query(params[:q])}%",
        "%#{sanitize_query(params[:q])}%"
      ).limit(10).map { |user| format_external_user_for_search(user) }

      render json: external_users
    end

    private

    def set_external_user
      @external_user = ExternalUser.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_external_users_path, alert: t('admin.external_users.messages.not_found')
    end

    def external_user_params
      params.expect(external_user: %i[name company_name email password password_confirmation active])
    end

    def sanitized_external_user_params
      attrs = external_user_params
      if attrs[:password].blank? && attrs[:password_confirmation].blank?
        attrs = attrs.except(:password, :password_confirmation)
      end
      attrs
    end

    def apply_filters(scope)
      scope = scope.where(active: params[:active] == 'true') if params[:active].present?
      if params[:search].present?
        scope = scope.where('name ILIKE ? OR company_name ILIKE ?', "%#{params[:search]}%",
                            "%#{params[:search]}%")
      end
      scope
    end

    def sanitize_query(query)
      query.to_s.strip.gsub(/[%_]/, '\\\\\&')
    end

    def format_external_user_for_search(external_user)
      {
        id: external_user.id,
        name: external_user.name,
        company_name: external_user.company_name,
        email: external_user.email,
        active: external_user.active?
      }
    end
  end
end
