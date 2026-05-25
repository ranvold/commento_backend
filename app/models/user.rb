# frozen_string_literal: true

class User < ApplicationRecord
  USERNAME_FORMAT = /\A[^\s@]+\z/

  has_secure_password

  before_validation :normalize_username

  has_many :api_tokens, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notifications, foreign_key: :recipient_id, inverse_of: :recipient, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validate :username_must_be_a_single_word

  private

  def normalize_username
    self[:username] = username.to_s.strip.presence
  end

  def username_must_be_a_single_word
    return if username.blank? || USERNAME_FORMAT.match?(username)

    errors.add(:username, :single_word_without_spaces_or_at)
  end
end
