# frozen_string_literal: true

module PagyMeilisearchHelper
  def pagy_meilisearch(model_class, query:, limit: 10)
    search_results = model_class.search(query)
    total_count = search_results.length
    page = (params[:page] || 1).to_i
    offset = (page - 1) * limit

    pagy = Pagy.new(
      count: total_count,
      page: page,
      items: limit,
      size: 7
    )

    results = search_results[offset, limit] || []

    [pagy, results]
  end
end
