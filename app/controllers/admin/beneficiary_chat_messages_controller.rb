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

      chat_group = params[:chat_group] || 'professionals_only'

      conversation = ChatV2::UpsertConversation.call(
        service: 'beneficiaries',
        context_type: 'Beneficiary',
        context_id: @beneficiary.id,
        scope: chat_group,
        conversation_type: :group
      )

      message = ChatV2::SendMessage.call(
        conversation: conversation,
        sender: current_user,
        body: params.dig(:chat_message, :body) || params[:body],
        content_type: :text
      )

      respond_to do |format|
        if message.persisted?
          format.turbo_stream { head :ok }
          format.html do
            redirect_to admin_beneficiary_path(@beneficiary, tab: 'chat', chat_group: chat_group),
                        notice: 'Mensagem enviada.'
          end
        else
          format.turbo_stream { head :unprocessable_entity }
          format.html do
            redirect_to admin_beneficiary_path(@beneficiary, tab: 'chat', chat_group: chat_group),
                        alert: message.errors.full_messages.to_sentence
          end
        end
      end
    end

    private

    def set_beneficiary
      @beneficiary = Beneficiary.find(params[:beneficiary_id])
    end
  end
end
