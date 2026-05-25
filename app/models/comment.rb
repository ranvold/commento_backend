# frozen_string_literal: true

class Comment < ApplicationRecord
  MENTIONED_USERNAME_PATTERN = /(?<![A-Za-z0-9_.%+-])@([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}|[A-Za-z0-9_]+)/

  include Meilisearch::Rails
  extend Pagy::Search

  belongs_to :user
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :body, presence: true

  meilisearch do
    attribute :body
    attribute :created_at

    sortable_attributes [:created_at]
  end

  def mentioned_usernames
    body.to_s.scan(MENTIONED_USERNAME_PATTERN).flatten.uniq
  end
end
