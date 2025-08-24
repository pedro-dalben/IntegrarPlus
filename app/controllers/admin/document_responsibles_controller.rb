# frozen_string_literal: true

class Admin::DocumentResponsiblesController < Admin::BaseController
  before_action :set_document
  before_action :ensure_can_assign_responsibles

  def index
    @responsibles = @document.document_responsibles.includes(:professional)
    @professionals = Professional.active.ordered
  end

  def create
    professional_id = params[:professional_id]
    status = params[:status]

    begin
      professional = Professional.find(professional_id)
      @document.assign_responsible(professional, status)

      respond_to do |format|
        format.html do
          redirect_to admin_document_document_responsibles_path(@document), notice: 'Responsável atribuído com sucesso!'
        end
        format.json { render json: { success: true, message: 'Responsável atribuído com sucesso!' } }
      end
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.html do
          redirect_to admin_document_document_responsibles_path(@document), alert: 'Profissional não encontrado.'
        end
        format.json { render json: { error: 'Profissional não encontrado.' }, status: :not_found }
      end
    rescue StandardError => e
      respond_to do |format|
        format.html { redirect_to admin_document_document_responsibles_path(@document), alert: e.message }
        format.json { render json: { error: e.message }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    responsible = @document.document_responsibles.find(params[:id])
    status = responsible.status

    if @document.remove_responsible(status)
      respond_to do |format|
        format.html do
          redirect_to admin_document_document_responsibles_path(@document), notice: 'Responsável removido com sucesso!'
        end
        format.json { render json: { success: true, message: 'Responsável removido com sucesso!' } }
      end
    else
      respond_to do |format|
        format.html do
          redirect_to admin_document_document_responsibles_path(@document), alert: 'Erro ao remover responsável.'
        end
        format.json { render json: { error: 'Erro ao remover responsável.' }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_document
    @document = Document.find(params[:document_id])
  end

  def ensure_can_assign_responsibles
    return if current_user.admin?
    return if current_user.permit?('documents.assign_responsibles')
    return if current_user.professional&.can_assign_responsibles?

    redirect_to admin_document_path(@document), alert: 'Você não tem permissão para atribuir responsáveis.'
  end
end
