# frozen_string_literal: true

class ApiToken < ApplicationRecord
  TOKEN_LIFETIME = 24.hours

  belongs_to :user

  has_secure_token :token, length: 32

  validates :token, presence: true, uniqueness: true

  before_validation :set_expiration, on: :create

  scope :active, -> { where("expires_at > ?", Time.current) }

  private

  def set_expiration
    self[:expires_at] ||= TOKEN_LIFETIME.from_now
  end
end
