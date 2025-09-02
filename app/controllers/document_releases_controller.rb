# frozen_string_literal: true

class DocumentReleasesController < ApplicationController
  before_action :set_document
  before_action :ensure_can_edit_document

  def index
    @releases = @document.document_releases.includes(:version, :released_by).ordered
  end

  def new
    return if @document.can_be_released?

    redirect_to @document, alert: 'Documento não pode ser liberado no momento.'
    nil
  end

  def create
    unless @document.can_be_released?
      redirect_to @document, alert: 'Documento não pode ser liberado no momento.'
      return
    end

    begin
      release = @document.release_document!(current_user.professional)

      if release
        redirect_to @document, notice: "Documento liberado com sucesso como versão #{release.version_number}."
      else
        redirect_to @document, alert: 'Erro ao liberar documento.'
      end
    rescue StandardError => e
      redirect_to @document, alert: "Erro ao liberar documento: #{e.message}"
    end
  end

  def download
    release = @document.document_releases.find(params[:id])

    if release.released_file_exists?
      send_file Rails.root.join(release.released_version_path),
                filename: "#{@document.title}_v#{release.version_number}#{File.extname(release.version.file_path)}"
    else
      redirect_to @document, alert: 'Arquivo liberado não encontrado.'
    end
  end

  private

  def set_document
    @document = Document.find(params[:document_id])
  end

  def ensure_can_edit_document
    return if @document.professional_can_edit?(current_user.professional)

    redirect_to @document, alert: 'Você não tem permissão para liberar este documento.'
  end
end
