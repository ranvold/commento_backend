# frozen_string_literal: true

module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_content
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActionController::ParameterMissing, with: :bad_request
    rescue_from UnauthorizedError, with: :unauthorized
  end

  private

  def unauthorized(exception)
    render_error(exception.message, :unauthorized)
  end

  def bad_request(exception)
    render_error(exception.message, :bad_request)
  end

  def not_found(exception)
    render_error(exception.message, :not_found)
  end

  def unprocessable_content(exception)
    render json: { message: exception.message, errors: exception.record.errors.as_json },
           status: :unprocessable_content
  end

  def render_error(message, status)
    render json: { message: message }, status: status
  end
end
