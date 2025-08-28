# frozen_string_literal: true

module Admin
  class DocumentsController < Admin::BaseController
    before_action :set_document, only: %i[show edit update destroy download upload_version]
    before_action :ensure_can_view, only: %i[show download]
    before_action :ensure_can_edit, only: %i[edit update destroy upload_version]
    before_action :ensure_can_create_documents, only: %i[new create]

    ALLOWED_FILE_TYPES = %w[.pdf .docx .xlsx .jpg .jpeg .png].freeze
    MAX_FILE_SIZE = 50.megabytes

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

      respond_to do |format|
        format.html do
          if request.xhr?
            render partial: 'search_results', layout: false
          end
        end
        format.json { render json: { results: @documents, count: @pagy.count } }
      end
    end

    def show; end

    def new
      @document = Document.new
    end

    def edit; end

    def create
      @document = Document.new(document_params)
      @document.author = current_user.professional

      if @document.save
        handle_file_upload if params[:document][:file].present?

        redirect_to admin_document_path(@document), notice: 'Documento criado com sucesso!'
      else
        render :new, status: :unprocessable_entity
      end
    rescue StandardError => e
      Rails.logger.error "Erro ao criar documento: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      @document.errors.add(:base, "Erro ao criar documento: #{e.message}")
      render :new, status: :unprocessable_entity
    end

    def update
      if @document.update(document_params)
        redirect_to admin_document_path(@document), notice: 'Documento atualizado com sucesso!'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @document.destroy
      redirect_to admin_documents_path, notice: 'Documento excluído com sucesso!'
    end

    def download
      version = @document.latest_version
      return redirect_to admin_document_path(@document), alert: 'Versão não encontrada!' unless version&.file_exists?

      file_path = Rails.root.join('storage', version.file_path)
      send_file file_path, filename: "#{@document.title}_v#{version.version_number}#{version.file_extension}"
    end

    def upload_version
      file = params[:file]
      notes = params[:notes]

      return render json: { error: 'Arquivo é obrigatório' }, status: :unprocessable_entity if file.blank?

      unless valid_file?(file)
        return render json: { error: 'Tipo de arquivo não permitido ou tamanho excedido' },
                      status: :unprocessable_entity
      end

      begin
        version = @document.create_new_version(file, current_user.professional, notes)
        render json: {
          success: true,
          version: version.version_number,
          message: 'Nova versão criada com sucesso!'
        }
      rescue StandardError => e
        Rails.logger.error "Erro ao criar versão: #{e.message}"
        render json: { error: 'Erro ao processar arquivo' }, status: :unprocessable_entity
      end
    end

    private

    def perform_local_search
      Document.includes(:author, :document_versions)
              .where(author_professional_id: current_user.professional.id)
              .where.not(status: 'liberado')
              .order(created_at: :desc)
    end

    def build_search_filters
      filters = {}
      filters[:author_professional_id] = current_user.professional.id
      filters[:status] = '!liberado'
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
      direction = params[:direction] || 'desc'

      case order_by
      when 'title'
        "title:#{direction}"
      when 'updated_at'
        "updated_at:#{direction}"
      when 'created_at'
        "created_at:#{direction}"
      else
        'created_at:desc'
      end
    end

    def set_document
      @document = Document.find(params[:id])
    end

    def document_params
      params.expect(document: %i[title description document_type category status file])
    end

    def handle_file_upload
      file = params[:document][:file]
      return unless valid_file?(file)

      begin
        @document.create_new_version(file, current_user.professional, 'Versão inicial')
      rescue StandardError => e
        Rails.logger.error "Erro no upload do arquivo: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        @document.errors.add(:file, "Erro ao processar arquivo: #{e.message}")
        raise e
      end
    end

    def valid_file?(file)
      return false unless file.respond_to?(:original_filename) && file.respond_to?(:size)

      extension = File.extname(file.original_filename).downcase
      return false unless ALLOWED_FILE_TYPES.include?(extension)
      return false if file.size > MAX_FILE_SIZE

      true
    end

    def ensure_can_view
      return if @document.user_can_view?(current_user)

      redirect_to admin_documents_path, alert: 'Você não tem permissão para visualizar este documento.'
    end

    def ensure_can_edit
      return if @document.user_can_edit?(current_user)

      redirect_to admin_document_path(@document), alert: 'Você não tem permissão para editar este documento.'
    end

    def ensure_can_create_documents
      return if current_user.admin?
      return if current_user.permit?('documents.create')
      return if current_user.professional&.can_create_documents?

      redirect_to admin_workspace_path, alert: 'Você não tem permissão para criar documentos.'
    end
  end
end
