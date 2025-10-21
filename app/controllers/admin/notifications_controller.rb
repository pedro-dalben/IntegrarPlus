# frozen_string_literal: true

module Admin
  class NotificationsController < Admin::BaseController
    before_action :set_notification, only: %i[show mark_as_read mark_as_unread destroy]
    before_action :authorize_notification

    def index
      @notifications = current_user.notifications
                                   .includes(:user)
                                   .order(created_at: :desc)

      @notifications = @notifications.where(read: params[:read]) if params[:read].present?
      @notifications = @notifications.by_type(params[:type]) if params[:type].present?
      @notifications = @notifications.by_channel(params[:channel]) if params[:channel].present?

      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @notifications = @notifications.where(
          'title ILIKE ? OR message ILIKE ?',
          search_term, search_term
        )
      end

      # Calcular contadores baseados nas notificações filtradas
      @unread_count = @notifications.unread.count
      @read_count = @notifications.read.count
      @total_count = @notifications.count

      @notification_types = Notification.types.keys
      @notification_channels = Notification.channels.keys
    end

    def show; end

    def mark_as_read
      @notification.mark_as_read!

      respond_to do |format|
        format.html { redirect_to admin_notifications_path, notice: 'Notificação marcada como lida.' }
        format.json { render json: { status: 'success' } }
      end
    end

    def mark_as_unread
      @notification.mark_as_unread!

      respond_to do |format|
        format.html { redirect_to admin_notifications_path, notice: 'Notificação marcada como não lida.' }
        format.json { render json: { status: 'success' } }
      end
    end

    def mark_all_as_read
      current_user.notifications.unread.update_all(read: true, read_at: Time.current)

      respond_to do |format|
        format.html { redirect_to admin_notifications_path, notice: 'Todas as notificações foram marcadas como lidas.' }
        format.json { render json: { status: 'success' } }
      end
    end

    def destroy
      @notification.destroy!

      respond_to do |format|
        format.html { redirect_to admin_notifications_path, notice: 'Notificação removida.' }
        format.json { render json: { status: 'success' } }
      end
    end

    def unread_count
      count = current_user.notifications.unread.count

      render json: { count: count }
    end

    def preferences
      @preferences = current_user.notification_preferences.includes(:user)
      @notification_types = Notification.types.keys
    end

    def update_preferences
      params[:preferences].each do |type, channels|
        preference = current_user.notification_preferences.find_or_initialize_by(type: type)
        preference.update!(
          email_enabled: channels[:email] == '1',
          sms_enabled: channels[:sms] == '1',
          push_enabled: channels[:push] == '1'
        )
      end

      redirect_to preferences_admin_notifications_path, notice: 'Preferências atualizadas com sucesso.'
    end

    def templates
      @templates = NotificationTemplate.includes(:user).order(:type, :channel)
      @templates = @templates.by_type(params[:type]) if params[:type].present?
      @templates = @templates.by_channel(params[:channel]) if params[:channel].present?
      @templates = @templates.where(active: params[:active]) if params[:active].present?
    end

    def new_template
      @template = NotificationTemplate.new
    end

    def create_template
      @template = NotificationTemplate.new(template_params)

      if @template.save
        redirect_to templates_admin_notifications_path, notice: 'Template criado com sucesso.'
      else
        render :new_template, status: :unprocessable_entity
      end
    end

    def edit_template
      @template = NotificationTemplate.find(params[:template_id])
    end

    def update_template
      @template = NotificationTemplate.find(params[:template_id])

      if @template.update(template_params)
        redirect_to templates_admin_notifications_path, notice: 'Template atualizado com sucesso.'
      else
        render :edit_template, status: :unprocessable_entity
      end
    end

    def destroy_template
      @template = NotificationTemplate.find(params[:template_id])
      @template.destroy!

      redirect_to templates_admin_notifications_path, notice: 'Template removido com sucesso.'
    end

    def create_default_templates
      NotificationTemplate.create_default_templates
      redirect_to templates_admin_notifications_path, notice: 'Templates padrão criados com sucesso.'
    end

    private

    def set_notification
      @notification = current_user.notifications.find(params[:id])
    end

    def authorize_notification
      authorize :notification, :index?
    end

    def template_params
      params.expect(
        notification_template: [:name, :type, :channel, :subject, :body, :active,
                                { variables: {} }]
      )
    end
  end
end
