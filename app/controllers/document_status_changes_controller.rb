# frozen_string_literal: true

class DocumentStatusChangesController < ApplicationController
  before_action :set_document
  before_action :ensure_can_edit_document

  def index
    @status_logs = @document.document_status_logs.includes(:user).ordered
  end

  def new
    @available_transitions = @document.available_status_transitions
  end

  def create
    new_status = params[:document][:status]
    notes = params[:document][:status_notes]

    unless @document.can_transition_to?(new_status)
      redirect_to @document, alert: 'Transição de status não permitida.'
      return
    end

    begin
      @document.update_status!(new_status, current_professional, notes)
      redirect_to @document, notice: "Status alterado para #{@document.status.humanize} com sucesso."
    rescue StandardError => e
      redirect_to @document, alert: "Erro ao alterar status: #{e.message}"
    end
  end

  private

  def set_document
    @document = Document.find(params[:document_id])
  end

  def ensure_can_edit_document
    return if @document.user_can_edit?(current_user)

    redirect_to @document, alert: 'Você não tem permissão para alterar o status deste documento.'
  end
end
