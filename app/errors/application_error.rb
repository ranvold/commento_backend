# frozen_string_literal: true

class ApplicationError < StandardError
  attr_reader :status

  def initialize(message: "Internal Server Error", status: :internal_server_error)
    super(message)

    @status = status
  end
end
