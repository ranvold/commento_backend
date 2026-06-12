# frozen_string_literal: true

config = if Rails.env.production? && ENV.fetch("MEILISEARCH_ACTIVATED", "false").downcase == "true"
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
