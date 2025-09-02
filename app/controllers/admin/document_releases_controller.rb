# frozen_string_literal: true

module Admin
  class DocumentReleasesController < Admin::BaseController
    before_action :set_document

    def index
      @releases = @document.document_releases.includes(:released_by).order(created_at: :desc)
    end

    def new
      @release = @document.document_releases.build
    end

    def create
      unless @document.can_be_released?
        redirect_to admin_document_path(@document),
                    alert: 'Documento não pode ser liberado. Status deve ser "Aguardando Liberação".'
        return
      end

      begin
        @release = @document.release_document!(current_user.professional)
        redirect_to admin_released_documents_path,
                    notice: 'Documento liberado com sucesso! Agora está disponível na seção de Documentos Liberados.'
      rescue StandardError => e
        Rails.logger.error "Erro ao liberar documento #{@document.id}: #{e.message}"
        redirect_to admin_document_path(@document),
                    alert: "Erro ao liberar documento: #{e.message}"
      end
    end

    def download
      @release = @document.document_releases.find(params[:id])

      if @release.file_exists?
        file_path = Rails.root.join('storage', @release.file_path)
        send_file file_path, filename: "#{@document.title}_release_#{@release.id}#{@release.file_extension}"
      else
        redirect_to admin_document_document_releases_path(@document), alert: 'Arquivo não encontrado!'
      end
    end

    private

    def set_document
      @document = Document.find(params[:document_id])
    end

    def release_params
      params.expect(document_release: %i[version notes file])
    end
  end
end
