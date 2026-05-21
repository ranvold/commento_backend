# frozen_string_literal: true

config = {
  meilisearch_url: ENV.fetch("MEILISEARCH_HOST", "https://ms-5d991e853146-48113.par.meilisearch.io"),
  meilisearch_api_key: ENV.fetch("MEILISEARCH_API_KEY", "dda0da1727556fee50a4fa5ff290ea1913b4f7de")
}
config[:active] = false if Rails.env.test?

Meilisearch::Rails.configuration = config
