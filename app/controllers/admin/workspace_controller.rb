# frozen_string_literal: true

class Admin::WorkspaceController < Admin::BaseController
  before_action :ensure_can_access_documents

  def index
    # Se não pode criar documentos, mostrar apenas onde é responsável
    @documents = if current_user.admin? || current_user.permit?('documents.create') || current_user.professional&.can_create_documents?
                   Document.includes(:author, :document_versions, :document_responsibles)
                           .where.not(status: 'liberado')
                 else
                   Document.joins(:document_responsibles)
                           .where(document_responsibles: { professional: current_user.professional })
                           .where.not(status: 'liberado')
                           .includes(:author, :document_versions, :document_responsibles)
                 end

    # Filtro "Meus documentos" - onde o usuário é responsável
    if params[:my_documents] == 'true'
      @documents = @documents.joins(:document_responsibles)
                             .where(document_responsibles: { professional: current_user.professional })
    end

    # Filtros
    @documents = @documents.where(status: params[:status]) if params[:status].present?
    @documents = @documents.where(document_type: params[:document_type]) if params[:document_type].present?
    @documents = @documents.where(author_professional_id: params[:author_id]) if params[:author_id].present?

    if params[:responsible_id].present?
      @documents = @documents.joins(:document_responsibles)
                             .where(document_responsibles: { professional_id: params[:responsible_id] })
    end

    # Filtros de data
    if params[:updated_after].present?
      @documents = @documents.where('documents.updated_at >= ?', Date.parse(params[:updated_after]))
    end

    if params[:updated_before].present?
      @documents = @documents.where('documents.updated_at <= ?', Date.parse(params[:updated_before]))
    end

    # Ordenação
    order_by = params[:order_by] || 'updated_at'
    direction = params[:direction] || 'desc'

    @documents = case order_by
                 when 'title'
                   @documents.order("documents.title #{direction}")
                 when 'author'
                   @documents.joins(:author).order("professionals.full_name #{direction}")
                 when 'status'
                   @documents.order("documents.status #{direction}")
                 when 'updated_at'
                   @documents.order("documents.updated_at #{direction}")
                 when 'created_at'
                   @documents.order("documents.created_at #{direction}")
                 else
                   @documents.order('documents.updated_at DESC')
                 end

    @pagy, @documents = pagy(@documents, items: 20)

    # Dados para filtros
    @statuses = Document.statuses.keys
    @document_types = Document.document_types.keys
    @authors = Professional.joins(:documents).distinct.order(:full_name)
    @responsibles = Professional.joins(:document_responsibles).distinct.order(:full_name)

    # Estatísticas
    @total_documents = Document.where.not(status: 'liberado').count
    @my_documents_count = Document.joins(:document_responsibles)
                                  .where(document_responsibles: { professional: current_user.professional })
                                  .where.not(status: 'liberado')
                                  .count
  end

  private

  def ensure_can_access_documents
    return if current_user.admin?
    return if current_user.permit?('documents.access')
    return if current_user.professional&.can_access_documents?

    redirect_to admin_path, alert: 'Você não tem permissão para acessar documentos.'
  end
end
