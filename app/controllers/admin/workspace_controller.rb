# frozen_string_literal: true

module Admin
  class WorkspaceController < Admin::BaseController
    before_action :ensure_can_access_documents

    def index
      if params[:query].present?
        begin
          search_service = AdvancedSearchService.new(Document)
          filters = build_search_filters
          options = build_search_options

          search_results = search_service.search(params[:query], filters, options)

          page = (params[:page] || 1).to_i
          per_page = 20
          offset = (page - 1) * per_page

          @documents = search_results[offset, per_page] || []
          @pagy = Pagy.new(count: search_results.length, page: page, items: per_page)
        rescue StandardError => e
          Rails.logger.error "Erro na busca avançada: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          @documents = perform_local_search_with_query
          @pagy, @documents = pagy(@documents, items: 20)
        end
      else
        @documents = perform_local_search
        @pagy, @documents = pagy(@documents, items: 20)
      end

      # Dados para filtros
      @statuses = Document.statuses.keys
      @document_types = Document.document_types.keys
      @authors = Professional.joins(:documents).distinct.order(:full_name)
      @responsibles = Professional.joins(:document_responsibles).distinct.order(:full_name)

      respond_to do |format|
        format.html do
          if request.xhr?
            render partial: 'search_results', layout: false
          end
        end
        format.json { render json: { results: @documents, count: @pagy.count } }
      end

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

    def perform_local_search_with_query
      # Busca local com query (fallback)
      documents = perform_local_search

      if params[:query].present?
        query = params[:query].downcase
        documents = documents.where(
          'LOWER(documents.title) LIKE ? OR LOWER(documents.description) LIKE ?',
          "%#{query}%", "%#{query}%"
        )
      end

      documents
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
        documents = documents.where(documents: { updated_at: Date.parse(params[:updated_after]).. })
      end

      if params[:updated_before].present?
        documents = documents.where(documents: { updated_at: ..Date.parse(params[:updated_before]) })
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

    def build_search_filters
      filters = {}

      # Filtro de status (excluir liberados)
      filters[:status] = '!liberado'

      # Filtro de permissões
      unless current_user.admin? || current_user.permit?('documents.create') || current_user.professional&.can_create_documents?
        filters[:author_professional_id] = current_user.professional.id
      end

      # Filtros adicionais
      if params[:status].present?
        filters[:status] = params[:status]
      end

      if params[:document_type].present?
        filters[:document_type] = params[:document_type]
      end

      if params[:category].present?
        filters[:category] = params[:category]
      end

      if params[:author_id].present?
        filters[:author_professional_id] = params[:author_id]
      end

      filters
    end

    def build_search_options
      {
        limit: 1000,
        sort: [build_sort_param]
      }
    end

    def build_base_filters
      filters = []

      # Filtro de status (excluir liberados) - usar valor numérico do enum
      filters << 'status != 3'

      # Filtro de permissões
      unless current_user.admin? || current_user.permit?('documents.create') || current_user.professional&.can_create_documents?
        # Se não pode criar, mostrar apenas onde é responsável
        filters << "author_professional_id = #{current_user.professional.id}"
      end

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
        'updated_at:desc'
      end
    end

    def ensure_can_access_documents
      return if current_user.admin?
      return if current_user.permit?('documents.access')
      return if current_user.professional&.can_access_documents?

      redirect_to admin_path, alert: 'Você não tem permissão para acessar documentos.'
    end
  end
end
