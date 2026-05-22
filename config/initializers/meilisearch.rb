# frozen_string_literal: true

config = if Rails.env.production?
  {
    meilisearch_url: ENV.fetch("MEILISEARCH_HOST"),
    meilisearch_api_key: ENV.fetch("MEILISEARCH_API_KEY")
  }
else
  {
    active: false
  }
end

Meilisearch::Rails.configuration = config
