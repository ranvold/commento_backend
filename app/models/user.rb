# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :api_tokens, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :username, presence: true, uniqueness: true

  def signup!
    self.class.transaction do
      save!
      login!
    end
  end

  def login!
    api_tokens.create!
  end
end
