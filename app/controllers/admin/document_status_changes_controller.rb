# frozen_string_literal: true

class Admin::DocumentStatusChangesController < Admin::BaseController
  before_action :set_document

  def index
    @status_logs = @document.document_status_logs.includes(:professional).ordered
  end

  def new
    @available_transitions = @document.available_status_transitions
  end

  def create
    new_status = params[:document][:status]
    notes = params[:document][:status_notes]

    unless @document.can_transition_to?(new_status)
      redirect_to admin_document_path(@document), alert: 'Transição de status não permitida.'
      return
    end

    begin
      @document.update_status!(new_status, current_professional, notes)
      redirect_to admin_document_path(@document),
                  notice: "Status alterado para #{@document.status.humanize} com sucesso."
    rescue StandardError => e
      redirect_to admin_document_path(@document), alert: "Erro ao alterar status: #{e.message}"
    end
  end

  private

  def set_document
    @document = Document.find(params[:document_id])
  end
end
