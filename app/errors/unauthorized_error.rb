# frozen_string_literal: true

class UnauthorizedError < ApplicationError
  def initialize(msg = "Unauthorized")
    super(message: msg, status: :unauthorized)
  end
end
