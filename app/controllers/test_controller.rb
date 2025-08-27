# frozen_string_literal: true

class TestController < ApplicationController
  def search_test
    if params[:query].present?
      begin
        search_service = AdvancedSearchService.new(Professional)
        filters = {}
        options = { limit: 10 }

        @results = search_service.search(params[:query], filters, options)
        @query = params[:query]
      rescue StandardError => e
        Rails.logger.error "Erro no teste de busca: #{e.message}"
        @error = e.message
        @results = []
      end
    else
      @results = []
    end
  end
end
