# frozen_string_literal: true

module Users
  class SearchQuery
    SEARCH_LIMIT  = 32
    DEFAULT_LIMIT = 64

    def initialize(relation = User.all)
      @relation = relation
    end

    def call(query: nil)
      if query.present?
        @relation
          .where("username ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(query)}%")
          .order(username: :asc)
          .limit(SEARCH_LIMIT)
      else
        @relation.order(created_at: :desc).limit(DEFAULT_LIMIT)
      end
    end
  end
end
