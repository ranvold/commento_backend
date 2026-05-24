# frozen_string_literal: true

module Comments
  class SearchQuery
    def initialize(relation = Comment.includes(:user))
      @relation = relation
    end

    def call(query: nil)
      @relation
        .order(created_at: :desc)
        .then { |rel| filter_by_body(rel, query) }
    end

    private

    def filter_by_body(relation, query)
      return relation if query.blank?

      relation.where("body ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(query)}%")
    end
  end
end
