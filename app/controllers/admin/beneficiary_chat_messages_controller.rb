# frozen_string_literal: true

module Admin
  class BeneficiaryChatMessagesController < BaseController
    before_action :set_beneficiary

    def create
      unless current_user.admin? || current_user.permit?('beneficiary.tabs.chat.edit')
        respond_to do |format|
          format.turbo_stream { head :forbidden }
          format.html do
            redirect_to admin_beneficiary_path(@beneficiary, tab: 'chat'), alert: 'Sem permissão para enviar mensagens.'
          end
        end
        return
      end

      chat_group = determine_chat_group
      @message = @beneficiary.beneficiary_chat_messages.build(message_params.merge(user: current_user,
                                                                                   chat_group: chat_group))

      respond_to do |format|
        if @message.save
          format.turbo_stream
          format.html do
            redirect_to admin_beneficiary_path(@beneficiary, tab: 'chat', anchor: 'chat'), notice: 'Mensagem enviada.'
          end
        else
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace("chat_message_content_#{@beneficiary.id}", partial: 'admin/beneficiaries/tabs/chat_input', locals: { beneficiary: @beneficiary, message: @message }),
                   status: :unprocessable_entity
          end
          format.html do
            redirect_to admin_beneficiary_path(@beneficiary, tab: 'chat', anchor: 'chat'),
                        alert: @message.errors.full_messages.to_sentence
          end
        end
      end
    end

    def mark_as_read
      message = @beneficiary.beneficiary_chat_messages.find(params[:id])
      message.mark_as_read_by(current_user)

      # Broadcast para atualizar em todas as abas conectadas
      message.reload.broadcast_replace_to(
        "beneficiary_chat_#{@beneficiary.id}_#{message.chat_group}",
        target: "beneficiary_chat_message_#{message.id}",
        partial: 'admin/beneficiaries/tabs/chat_message',
        locals: { message: message }
      )

      respond_to do |format|
        format.json { head :ok }
        format.turbo_stream do
          # Atualizar apenas na aba atual com current_user
          render turbo_stream: turbo_stream.replace("beneficiary_chat_message_#{message.id}",
                                                    partial: 'admin/beneficiaries/tabs/chat_message', locals: { message: message.reload, current_user: current_user })
        end
      end
    end

    def mark_all_as_read
      unread_messages = @beneficiary.beneficiary_chat_messages.unread_by(current_user)
      unread_messages.find_each do |message|
        message.mark_as_read_by(current_user)
      end

      respond_to do |format|
        format.json { head :ok }
        format.turbo_stream { redirect_to admin_beneficiary_path(@beneficiary, tab: 'chat') }
      end
    end

    private

    def set_beneficiary
      @beneficiary = Beneficiary.find(params[:beneficiary_id])
    end

    def message_params
      params.fetch(:beneficiary_chat_message, {}).permit(:content, :chat_group)
    end

    def determine_chat_group
      chat_group_param = params.dig(:beneficiary_chat_message, :chat_group)
      return chat_group_param if chat_group_param.present? && BeneficiaryChatMessage.chat_groups.key?(chat_group_param)

      if current_user.professional&.secretary?
        'general'
      else
        'professionals_only'
      end
    end
  end
end
