# frozen_string_literal: true

module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :internal_server_error
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_content
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::ParameterMissing, with: :bad_request
    rescue_from UnauthorizedError, with: :unauthorized
  end

  private

  def internal_server_error(exception)
    Rails.logger.error(exception.full_message)

    render_error("Internal server error", :internal_server_error)
  end

  def unprocessable_content(exception)
    render_error(exception.record.errors.as_json, :unprocessable_content)
  end

  def not_found
    render_error("Record not found", :not_found)
  end

  def bad_request(exception)
    render_error(exception.message, :bad_request)
  end

  def unauthorized
    render_error("Unauthorized", :unauthorized)
  end

  def render_error(message, status)
    render json: { message: message }, status: status
  end
end
