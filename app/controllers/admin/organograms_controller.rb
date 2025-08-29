# frozen_string_literal: true

module Admin
  class OrganogramsController < Admin::BaseController
    before_action :set_organogram, only: [:show, :edit, :update, :destroy, :editor,
                                         :export_json, :export_pdf, :import_json,
                                         :import_csv, :publish, :unpublish]
    before_action :authorize_organogram, except: [:index, :new, :create]

    def index
      @organograms = policy_scope(Organogram).ordered
      @pagy, @organograms = pagy(@organograms, limit: 20)
    end

    def show
      respond_to do |format|
        format.html
        format.json { render json: @organogram.to_export_data }
      end
    end

    def new
      @organogram = Organogram.new
      authorize @organogram
    end

    def create
      @organogram = Organogram.new(organogram_params)
      @organogram.created_by = current_user
      authorize @organogram

      if @organogram.save
        redirect_to admin_organogram_path(@organogram),
                    notice: 'Organograma criado com sucesso!'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @organogram.update(organogram_params)
        respond_to do |format|
          format.html do
            redirect_to admin_organogram_path(@organogram),
                        notice: 'Organograma atualizado com sucesso!'
          end
          format.json { render json: { status: 'success', message: 'Salvo com sucesso!' } }
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: { status: 'error', errors: @organogram.errors } }
        end
      end
    end

    def destroy
      @organogram.destroy
      redirect_to admin_organograms_path,
                  notice: 'Organograma excluído com sucesso!'
    end

    def editor
      respond_to do |format|
        format.html
        format.json { render json: @organogram.to_export_data }
      end
    end

    def export_json
      send_data @organogram.to_export_data.to_json,
                filename: "organograma-#{@organogram.id}.json",
                type: 'application/json',
                disposition: 'attachment'
    end

    def export_pdf
      if ENV['ORGCHART_PDF_SERVER'] == 'true'
        require 'grover'
        url = admin_organogram_url(@organogram, only_path: false)
        pdf = Grover.new(url, format: 'A4', landscape: true, print_background: true).to_pdf
        send_data pdf, filename: "organograma-#{@organogram.id}.pdf", type: 'application/pdf'
      else
        head :not_found
      end
    end

    def import_json
      uploaded_file = params[:file]

      if uploaded_file.blank?
        redirect_to admin_organogram_editor_path(@organogram),
                    alert: 'Nenhum arquivo selecionado'
        return
      end

      begin
        json_data = JSON.parse(uploaded_file.read)

        if json_data['nodes'].present?
          @organogram.data = {
            nodes: json_data['nodes'],
            links: json_data['links'] || []
          }
          @organogram.settings = json_data['settings'] if json_data['settings'].present?

          if @organogram.save
            redirect_to admin_organogram_editor_path(@organogram),
                        notice: 'Organograma importado com sucesso!'
          else
            redirect_to admin_organogram_editor_path(@organogram),
                        alert: "Erro ao importar: #{@organogram.errors.full_messages.join(', ')}"
          end
        else
          redirect_to admin_organogram_editor_path(@organogram),
                      alert: 'Arquivo JSON inválido: deve conter estrutura de nodes'
        end
      rescue JSON::ParserError
        redirect_to admin_organogram_editor_path(@organogram),
                    alert: 'Arquivo JSON inválido'
      rescue StandardError => e
        Rails.logger.error "Erro ao importar JSON: #{e.message}"
        redirect_to admin_organogram_editor_path(@organogram),
                    alert: 'Erro interno ao processar o arquivo'
      end
    end

    def import_csv
      uploaded_file = params[:file]

      if uploaded_file.blank?
        redirect_to admin_organogram_editor_path(@organogram),
                    alert: 'Nenhum arquivo selecionado'
        return
      end

      begin
        require 'csv'

        csv_data = CSV.parse(uploaded_file.read, headers: true, encoding: 'UTF-8')
        processed_data = []

        csv_data.each do |row|
          processed_data << {
            'id' => row['id'],
            'pid' => row['pid'],
            'name' => row['name'],
            'role_title' => row['role_title'],
            'department' => row['department'],
            'email' => row['email'],
            'phone' => row['phone']
          }
        end

        @organogram.from_csv_data(processed_data)

        if @organogram.save
          redirect_to admin_organogram_editor_path(@organogram),
                      notice: 'CSV importado com sucesso!'
        else
          redirect_to admin_organogram_editor_path(@organogram),
                      alert: "Erro ao importar: #{@organogram.errors.full_messages.join(', ')}"
        end
      rescue CSV::MalformedCSVError
        redirect_to admin_organogram_editor_path(@organogram),
                    alert: 'Arquivo CSV mal formatado'
      rescue StandardError => e
        Rails.logger.error "Erro ao importar CSV: #{e.message}"
        redirect_to admin_organogram_editor_path(@organogram),
                    alert: 'Erro interno ao processar o arquivo'
      end
    end

    def publish
      if @organogram.publish!
        redirect_to admin_organogram_path(@organogram),
                    notice: 'Organograma publicado com sucesso!'
      else
        redirect_to admin_organogram_path(@organogram),
                    alert: 'Erro ao publicar organograma'
      end
    end

    def unpublish
      if @organogram.unpublish!
        redirect_to admin_organogram_path(@organogram),
                    notice: 'Organograma despublicado com sucesso!'
      else
        redirect_to admin_organogram_path(@organogram),
                    alert: 'Erro ao despublicar organograma'
      end
    end

    private

    def set_organogram
      @organogram = Organogram.find(params[:id])
    end

    def authorize_organogram
      authorize @organogram
    end

    def organogram_params
      params.require(:organogram).permit(:name, :data, :settings,
                                        data: {}, settings: {})
    end
  end
end
