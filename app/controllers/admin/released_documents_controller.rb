# frozen_string_literal: true

module Admin
  class ReleasedDocumentsController < Admin::BaseController
    before_action :ensure_can_view_released

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
          @documents = perform_local_search
          @pagy, @documents = pagy(@documents, items: 20)
        end
      else
        @documents = perform_local_search
        @pagy, @documents = pagy(@documents, items: 20)
      end

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

    def perform_local_search
      documents = Document.includes(:author, :document_versions, :document_responsibles)
                          .where(status: 'liberado')

      # Filtros
      documents = documents.where(document_type: params[:document_type]) if params[:document_type].present?
      documents = documents.where(category: params[:category]) if params[:category].present?
      documents = documents.where(author_professional_id: params[:author_id]) if params[:author_id].present?
      if params[:responsible_id].present?
        documents = documents.joins(:document_responsibles).where(document_responsibles: { professional_id: params[:responsible_id] })
      end

      # Ordenação
      order_by = params[:order_by] || 'created_at'
      order_direction = params[:order_direction] || 'desc'

      case order_by
      when 'title'
        documents.order("documents.title #{order_direction}")
      when 'author'
        documents.joins(:author).order("professionals.full_name #{order_direction}")
      when 'created_at'
        documents.order("documents.created_at #{order_direction}")
      when 'released_at'
        documents.joins(:document_releases).order("document_releases.created_at #{order_direction}")
      else
        documents.order('documents.created_at DESC')
      end
    end

    def build_search_filters
      filters = {}

      # Filtro de status (apenas liberados)
      filters[:status] = 'liberado'

      # Filtros adicionais
      filters[:document_type] = params[:document_type] if params[:document_type].present?

      filters[:category] = params[:category] if params[:category].present?

      filters[:author_professional_id] = params[:author_id] if params[:author_id].present?

      filters
    end

    def build_search_options
      {
        limit: 1000,
        sort: [build_sort_param]
      }
    end

    def build_sort_param
      order_by = params[:order_by] || 'created_at'
      direction = params[:order_direction] || 'desc'

      case order_by
      when 'title'
        "title:#{direction}"
      when 'created_at'
        "created_at:#{direction}"
      when 'updated_at'
        "updated_at:#{direction}"
      else
        'created_at:desc'
      end
    end

    def ensure_can_view_released
      return if current_user.admin?
      return if current_user.permit?('documents.view_released')
      return if current_user.professional&.can_view_released?

      redirect_to admin_path, alert: 'Você não tem permissão para ver documentos liberados.'
    end
  end
end
