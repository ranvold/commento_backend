# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  TOKEN_AUTH = ActionController::HttpAuthentication::Token

  included do
    before_action :require_authentication
  end

  class_methods do
    def allow_unauthenticated_access(**)
      skip_before_action(:require_authentication, **)
    end
  end

  private

  def require_authentication
    passed_token, = TOKEN_AUTH.token_and_options(request)

    raise UnauthorizedError unless passed_token

    api_token = ApiToken.active.find_by(token: passed_token)

    raise UnauthorizedError unless api_token

    Current.user = api_token.user
    Current.api_token = api_token
  end
end
