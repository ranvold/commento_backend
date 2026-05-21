# frozen_string_literal: true

class Comment < ApplicationRecord
  include Meilisearch::Rails
  extend Pagy::Search

  belongs_to :user

  validates :body, presence: true

  meilisearch do
    attribute :body
    attribute :created_at

    sortable_attributes [:created_at]
  end
end
