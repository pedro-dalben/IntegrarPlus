module Admin
  class PublicFlowChartsController < BaseController
    before_action :set_flow_chart, only: %i[show view]

    def index
      @flow_charts = FlowChart.published.includes(:created_by, :current_version)
                              .order(updated_at: :desc)
                              .page(params[:page])
    end

    def show
      @current_version = @flow_chart.current_version
      @versions = @flow_chart.versions.ordered
    end

    def view
      @current_version = @flow_chart.current_version
      @versions = @flow_chart.versions.ordered
    end

    private

    def set_flow_chart
      @flow_chart = FlowChart.published.find(params[:id])
    end
  end
end
