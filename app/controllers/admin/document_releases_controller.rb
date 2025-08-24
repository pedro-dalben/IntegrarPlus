# frozen_string_literal: true

class Admin::DocumentReleasesController < Admin::BaseController
  before_action :set_document

  def index
    @releases = @document.document_releases.includes(:professional).order(created_at: :desc)
  end

  def new
    @release = @document.document_releases.build
  end

  def create
    @release = @document.document_releases.build(release_params)
    @release.professional = current_user.professional

    if @release.save
      redirect_to admin_document_document_releases_path(@document), notice: 'Release criado com sucesso!'
    else
      render :new, status: :unprocessable_entity
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
    params.require(:document_release).permit(:version, :notes, :file)
  end
end
