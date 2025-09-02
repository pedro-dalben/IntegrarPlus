# frozen_string_literal: true

class DocumentResponsiblesController < ApplicationController
  before_action :set_document
  before_action :ensure_can_edit_document

  def index
    @responsibles = @document.document_responsibles.includes(:user).ordered
    @available_users = User.all
  end

  def create
    user = User.find(params[:document_responsible][:user_id])
    status = params[:document_responsible][:status]

    begin
      @document.assign_responsible(user, status)
      redirect_to admin_document_document_responsibles_path(@document),
                  notice: 'Responsável atribuído com sucesso.'
    rescue StandardError => e
      redirect_to admin_document_document_responsibles_path(@document),
                  alert: "Erro ao atribuir responsável: #{e.message}"
    end
  end

  def destroy
    responsible = @document.document_responsibles.find(params[:id])
    responsible.destroy

    redirect_to admin_document_document_responsibles_path(@document),
                notice: 'Responsável removido com sucesso.'
  end

  private

  def set_document
    @document = Document.find(params[:document_id])
  end

  def ensure_can_edit_document
    return if @document.professional_can_edit?(current_user.professional)

    redirect_to @document, alert: 'Você não tem permissão para gerenciar responsáveis deste documento.'
  end
end
