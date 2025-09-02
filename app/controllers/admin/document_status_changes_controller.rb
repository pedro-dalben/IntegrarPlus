# frozen_string_literal: true

module Admin
  class DocumentStatusChangesController < Admin::BaseController
    before_action :set_document
    before_action :ensure_can_edit_document

    def index
      @status_logs = @document.document_status_logs.includes(:professional).ordered
    end

    def new
      @available_transitions = @document.available_status_transitions
    end

    def create
      new_status = params[:document]&.[](:status)
      notes = params[:document]&.[](:status_notes)

      if new_status.blank?
        redirect_to new_admin_document_document_status_change_path(@document),
                    alert: 'Por favor, selecione um novo status.'
        return
      end

      unless @document.can_transition_to?(new_status)
        redirect_to new_admin_document_document_status_change_path(@document),
                    alert: 'Transição de status não permitida.'
        return
      end

      begin
        @document.update_status!(new_status, current_professional, notes)
        redirect_to admin_document_path(@document),
                    notice: "Status alterado para #{@document.status.humanize} com sucesso."
      rescue StandardError => e
        Rails.logger.error "Erro ao alterar status do documento #{@document.id}: #{e.message}"
        redirect_to new_admin_document_document_status_change_path(@document),
                    alert: "Erro ao alterar status: #{e.message}"
      end
    end

    private

    def set_document
      @document = Document.find(params[:document_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_documents_path, alert: 'Documento não encontrado.'
    end

    def ensure_can_edit_document
      return if @document.professional_can_edit?(current_user.professional)

      redirect_to admin_document_path(@document),
                  alert: 'Você não tem permissão para alterar o status deste documento.'
    end
  end
end
