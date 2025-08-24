# frozen_string_literal: true

class Admin::ReleasedDocumentsController < Admin::BaseController
  before_action :ensure_can_view_released

  def index
    @documents = Document.includes(:author, :document_versions, :document_responsibles)
                         .where(status: 'liberado')

    # Filtros
    @documents = @documents.where(document_type: params[:document_type]) if params[:document_type].present?
    @documents = @documents.where(author_professional_id: params[:author_id]) if params[:author_id].present?
    if params[:responsible_id].present?
      @documents = @documents.joins(:document_responsibles).where(document_responsibles: { professional_id: params[:responsible_id] })
    end

    # Ordenação
    order_by = params[:order_by] || 'created_at'
    order_direction = params[:order_direction] || 'desc'

    case order_by
    when 'title'
      @documents = @documents.order("documents.title #{order_direction}")
    when 'author'
      @documents = @documents.joins(:author).order("professionals.full_name #{order_direction}")
    when 'created_at'
      @documents = @documents.order("documents.created_at #{order_direction}")
    when 'released_at'
      @documents = @documents.joins(:document_releases).order("document_releases.created_at #{order_direction}")
    end

    # Paginação
    @pagy, @documents = pagy(@documents, items: 20)

    # Dados para filtros
    @authors = Professional.joins(:documents).distinct.order(:full_name)
    @responsibles = Professional.joins(:document_responsibles).distinct.order(:full_name)
  end

  def show
    @document = Document.includes(:author, :document_versions, :document_releases, :document_responsibles)
                        .find(params[:id])

    unless @document.status == 'liberado'
      redirect_to admin_workspace_path, alert: 'Documento não está liberado'
      return
    end

    @latest_release = @document.document_releases.order(:created_at).last
  end

  private

  def ensure_can_view_released
    return if current_user.admin?
    return if current_user.permit?('documents.view_released')
    return if current_user.professional&.can_view_released?

    redirect_to admin_path, alert: 'Você não tem permissão para ver documentos liberados.'
  end
end
