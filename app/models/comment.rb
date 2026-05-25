# frozen_string_literal: true

class Comment < ApplicationRecord
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
    body.to_s.scan(/@([a-zA-Z0-9_]+)/).flatten.uniq
  end
end
