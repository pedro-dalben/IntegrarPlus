module Admin
  class FlowChartsController < BaseController
    before_action :set_flow_chart, only: %i[show edit update destroy publish duplicate]
    before_action :authorize_flow_chart, except: %i[index new create]

    def index
      authorize FlowChart

      if params[:query].present?
        begin
          search_service = AdvancedSearchService.new(FlowChart)
          filters = build_search_filters
          options = build_search_options

          search_results = search_service.search(params[:query], filters, options)

          page = (params[:page] || 1).to_i
          per_page = 20
          offset = (page - 1) * per_page

          @flow_charts = search_results[offset, per_page] || []
          @pagy = Pagy.new(count: search_results.length, page: page, items: per_page)
        rescue StandardError => e
          Rails.logger.error "Erro na busca avançada: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          @flow_charts = perform_local_search
          @pagy, @flow_charts = pagy(@flow_charts, items: 20)
        end
      else
        @flow_charts = perform_local_search
        @pagy, @flow_charts = pagy(@flow_charts, items: 20)
      end

      respond_to do |format|
        format.html do
          render partial: 'search_results', layout: false if request.xhr?
        end
        format.json { render json: { results: @flow_charts, count: @pagy.count } }
      end
    end

    def show
      @current_version = @flow_chart.current_version
      @versions = @flow_chart.versions.ordered
    end

    def new
      @flow_chart = FlowChart.new
      authorize @flow_chart
    end

    def edit
      @current_version = @flow_chart.current_version
    end

    def create
      @flow_chart = FlowChart.new(flow_chart_params)
      @flow_chart.created_by = current_professional
      @flow_chart.updated_by = current_professional

      authorize @flow_chart

      if @flow_chart.save
        create_initial_version if params[:diagram_data].present?

        redirect_to edit_admin_flow_chart_path(@flow_chart),
                    notice: 'Fluxograma criado com sucesso. Agora você pode editá-lo no diagrama.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @flow_chart.updated_by = current_professional

      if params[:thumbnail_data].present?
        data_uri = params[:thumbnail_data].to_s
        if data_uri.start_with?('data:image/png;base64,')
          base64 = data_uri.split(',', 2)[1]
          decoded = Base64.decode64(base64)
          @flow_chart.thumbnail.attach(
            io: StringIO.new(decoded),
            filename: "flow_chart_#{@flow_chart.id}.png",
            content_type: 'image/png'
          )
        end

        render json: { success: true }, status: :ok and return
      end

      if params[:diagram_data].present?
        # Se está publicado e sendo editado, voltar para draft
        @flow_chart.update!(status: :draft) if @flow_chart.published?

        create_new_version
        respond_to do |format|
          format.json do
            render json: { success: true, version: @flow_chart.current_version.version }, status: :ok
          end
          format.html do
            redirect_to admin_flow_chart_path(@flow_chart),
                        notice: 'Fluxograma salvo com sucesso.'
          end
        end
      elsif @flow_chart.update(flow_chart_params)
        Rails.logger.info "Flow chart updated successfully: #{@flow_chart.id}"

        # Verificar se deve redirecionar para show (quando vem do saveAndSubmit)
        if params[:redirect_to_show] == 'true'
          redirect_to admin_flow_chart_path(@flow_chart),
                      notice: 'Fluxograma salvo com sucesso!'
        else
          redirect_to admin_flow_chart_path(@flow_chart),
                      notice: 'Fluxograma atualizado com sucesso.'
        end
      else
        Rails.logger.error "Flow chart update failed: #{@flow_chart.errors.full_messages}"
        @current_version = @flow_chart.current_version
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @flow_chart.destroy
      redirect_to admin_flow_charts_path, notice: 'Fluxograma excluído com sucesso.'
    end

    def publish
      if @flow_chart.can_publish?
        @flow_chart.publish!
        redirect_to admin_flow_chart_path(@flow_chart),
                    notice: 'Fluxograma publicado com sucesso.'
      else
        redirect_to admin_flow_chart_path(@flow_chart),
                    alert: 'Não é possível publicar um fluxograma sem versão.'
      end
    end

    def duplicate
      new_chart = @flow_chart.duplicate

      if new_chart.persisted?
        redirect_to edit_admin_flow_chart_path(new_chart),
                    notice: 'Fluxograma duplicado com sucesso.'
      else
        redirect_to admin_flow_chart_path(@flow_chart),
                    alert: 'Erro ao duplicar fluxograma.'
      end
    end

    def export_pdf
      @flow_chart = FlowChart.find(params[:id])
      authorize @flow_chart

      svg_data = params[:svg_data]

      if svg_data.blank?
        render json: { error: 'Dados SVG não fornecidos' }, status: :unprocessable_entity
        return
      end

      send_data svg_data,
                filename: "#{@flow_chart.title.parameterize}.svg",
                type: 'image/svg+xml',
                disposition: 'attachment'
    end

    private

    def set_flow_chart
      @flow_chart = FlowChart.find(params[:id])
    end

    def authorize_flow_chart
      authorize @flow_chart
    end

    def perform_local_search
      FlowChart.includes(:created_by, :current_version).ordered
    end

    def build_search_filters
      filters = {}
      filters[:status] = params[:status].to_i if params[:status].present?
      filters
    end

    def build_search_options
      {
        limit: 1000,
        sort: [build_sort_param]
      }
    end

    def build_sort_param
      order_by = params[:order_by] || 'updated_at'
      direction = params[:direction] || 'desc'

      case order_by
      when 'title'
        "title:#{direction}"
      when 'created_at'
        "created_at:#{direction}"
      when 'updated_at'
        "updated_at:#{direction}"
      else
        'updated_at:desc'
      end
    end

    def flow_chart_params
      params.expect(flow_chart: %i[title description status])
    end

    def create_initial_version
      version = @flow_chart.versions.build(
        data: params[:diagram_data],
        data_format: :xml,
        notes: 'Versão inicial',
        created_by: current_professional
      )

      return unless version.save

      @flow_chart.update(current_version: version)
    end

    def create_new_version
      version = @flow_chart.versions.build(
        data: params[:diagram_data],
        data_format: :xml,
        notes: params[:version_notes] || "Atualização em #{I18n.l(Time.current, format: :short)}",
        created_by: current_professional
      )

      return unless version.save

      @flow_chart.update(current_version: version)
    end
  end
end
