class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document, only: %i[show edit update destroy download upload_version]
  before_action :ensure_can_view, only: %i[show download]
  before_action :ensure_can_edit, only: %i[edit update destroy upload_version]

  ALLOWED_FILE_TYPES = %w[.pdf .docx .xlsx .jpg .jpeg .png].freeze
  MAX_FILE_SIZE = 50.megabytes

  def index
    @documents = current_user.documents.includes(:author, :document_versions)
                             .order(created_at: :desc)
                             .page(params[:page])
  end

  def show
  end

  def new
    @document = Document.new
  end

  def edit
  end

  def create
    @document = current_user.documents.build(document_params)
    @document.author = current_user

    if @document.save
      handle_file_upload if params[:document][:file].present?

      redirect_to @document, notice: 'Documento criado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @document.update(document_params)
      redirect_to @document, notice: 'Documento atualizado com sucesso!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @document.destroy
    redirect_to documents_path, notice: 'Documento excluído com sucesso!'
  end

  def download
    version = @document.latest_version
    return redirect_to @document, alert: 'Versão não encontrada!' unless version&.file_exists?

    file_path = Rails.root.join('storage', version.file_path)
    send_file file_path, filename: "#{@document.title}_v#{version.version_number}#{version.file_extension}"
  end

  def upload_version
    file = params[:file]
    notes = params[:notes]

    return render json: { error: 'Arquivo é obrigatório' }, status: :unprocessable_entity unless file.present?

    unless valid_file?(file)
      return render json: { error: 'Tipo de arquivo não permitido ou tamanho excedido' }, status: :unprocessable_entity
    end

    begin
      version = @document.create_new_version(file, current_user, notes)
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

  def set_document
    @document = Document.find(params[:id])
  end

  def document_params
    params.require(:document).permit(:title, :description, :document_type, :status)
  end

  def handle_file_upload
    file = params[:document][:file]
    return unless valid_file?(file)

    @document.create_new_version(file, current_user, 'Versão inicial')
  end

  def valid_file?(file)
    return false unless file.respond_to?(:original_filename) && file.respond_to?(:size)

    extension = File.extname(file.original_filename).downcase
    return false unless ALLOWED_FILE_TYPES.include?(extension)
    return false if file.size > MAX_FILE_SIZE

    true
  end

  def ensure_can_view
    unless @document.user_can_view?(current_user)
      redirect_to documents_path, alert: 'Você não tem permissão para visualizar este documento.'
    end
  end

  def ensure_can_edit
    unless @document.user_can_edit?(current_user)
      redirect_to @document, alert: 'Você não tem permissão para editar este documento.'
    end
  end
end
