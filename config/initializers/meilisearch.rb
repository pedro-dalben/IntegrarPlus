Meilisearch::Rails.configuration = {
  meilisearch_url: ENV.fetch('MEILISEARCH_HOST', 'http://localhost:7700'),
  meilisearch_api_key: ENV.fetch('MEILISEARCH_API_KEY', 'Drv8-9cnv0ydtlrSqRsdpQcSChBy5dK2t_WBS1fnebE')
}
