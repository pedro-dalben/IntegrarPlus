# frozen_string_literal: true

class Admin::WorkspaceController < Admin::BaseController
  before_action :ensure_can_access_documents

  def index
    # Busca com MeiliSearch (independente dos filtros)
    if params[:query].present?
      begin
        search_results = Document.search(params[:query], {
          filter: build_base_filters,
          sort: [build_sort_param]
        })

        # Paginação manual para resultados do MeiliSearch
        page = (params[:page] || 1).to_i
        per_page = 20
        offset = (page - 1) * per_page

        @documents = search_results[offset, per_page] || []
        @pagy = Pagy.new(count: search_results.length, page: page, items: per_page)
      rescue => e
        Rails.logger.error "Erro na busca MeiliSearch: #{e.message}"
        # Fallback para busca local
        @documents = perform_local_search_with_query
        @pagy, @documents = pagy(@documents, items: 20)
      end
    else
      # Busca local sem MeiliSearch (com filtros)
      @documents = perform_local_search
      @pagy, @documents = pagy(@documents, items: 20)
    end

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
                                  .distinct
                                  .count
  end

  private

  def perform_local_search
    # Se não pode criar documentos, mostrar apenas onde é responsável
    documents = if current_user.admin? || current_user.permit?('documents.create') || current_user.professional&.can_create_documents?
                   Document.includes(:author, :document_versions, :document_responsibles)
                           .where.not(status: 'liberado')
                 else
                   Document.joins(:document_responsibles)
                           .where(document_responsibles: { professional: current_user.professional })
                           .where.not(status: 'liberado')
                           .includes(:author, :document_versions, :document_responsibles)
                 end

    # Aplicar filtros e ordenação
    documents = apply_filters(documents)
    apply_sorting(documents)
  end

  def apply_filters(documents)
    # Filtro "Meus documentos" - onde o usuário é responsável
    if params[:my_documents] == 'true'
      documents = documents.joins(:document_responsibles)
                           .where(document_responsibles: { professional: current_user.professional })
    end

    # Filtros
    documents = documents.where(status: params[:status]) if params[:status].present?
    documents = documents.where(document_type: params[:document_type]) if params[:document_type].present?
    documents = documents.where(category: params[:category]) if params[:category].present?
    documents = documents.where(author_professional_id: params[:author_id]) if params[:author_id].present?

    if params[:responsible_id].present?
      documents = documents.joins(:document_responsibles)
                           .where(document_responsibles: { professional_id: params[:responsible_id] })
    end

    # Filtros de data
    if params[:updated_after].present?
      documents = documents.where('documents.updated_at >= ?', Date.parse(params[:updated_after]))
    end

    if params[:updated_before].present?
      documents = documents.where('documents.updated_at <= ?', Date.parse(params[:updated_before]))
    end

    documents
  end

  def apply_sorting(documents)
    # Ordenação
    order_by = params[:order_by] || 'updated_at'
    direction = params[:direction] || 'desc'

    case order_by
    when 'title'
      documents.order("documents.title #{direction}")
    when 'author'
      documents.joins(:author).order("professionals.full_name #{direction}")
    when 'status'
      documents.order("documents.status #{direction}")
    when 'updated_at'
      documents.order("documents.updated_at #{direction}")
    when 'created_at'
      documents.order("documents.created_at #{direction}")
    else
      documents.order('documents.updated_at DESC')
    end
  end

  def build_base_filters
    filters = []

    # Filtro de status (excluir liberados) - usar valor numérico do enum
    filters << "status != 3"

    # Filtro de permissões
    unless current_user.admin? || current_user.permit?('documents.create') || current_user.professional&.can_create_documents?
      # Se não pode criar, mostrar apenas onde é responsável
      filters << "author_professional_id = #{current_user.professional.id}"
    end

    filters.join(' AND ')
  end

  def build_search_filters
    filters = []

    # Filtro de status (excluir liberados) - usar valor numérico do enum
    filters << "status != 3"

    # Filtro de permissões
    unless current_user.admin? || current_user.permit?('documents.create') || current_user.professional&.can_create_documents?
      # Se não pode criar, mostrar apenas onde é responsável
      filters << "author_professional_id = #{current_user.professional.id}"
    end

    # Filtros adicionais - converter para valores numéricos dos enums
    if params[:status].present?
      status_value = Document.statuses[params[:status]]
      filters << "status = #{status_value}" if status_value
    end

    if params[:document_type].present?
      doc_type_value = Document.document_types[params[:document_type]]
      filters << "document_type = #{doc_type_value}" if doc_type_value
    end

    if params[:category].present?
      category_value = Document.categories[params[:category]]
      filters << "category = #{category_value}" if category_value
    end

    filters << "author_professional_id = #{params[:author_id]}" if params[:author_id].present?

    filters.join(' AND ')
  end

  def build_sort_param
    order_by = params[:order_by] || 'updated_at'
    direction = params[:direction] || 'desc'

    case order_by
    when 'title'
      "title:#{direction}"
    when 'updated_at'
      "updated_at:#{direction}"
    when 'created_at'
      "created_at:#{direction}"
    else
      "updated_at:desc"
    end
  end



  def ensure_can_access_documents
    return if current_user.admin?
    return if current_user.permit?('documents.access')
    return if current_user.professional&.can_access_documents?

    redirect_to admin_path, alert: 'Você não tem permissão para acessar documentos.'
  end
end
