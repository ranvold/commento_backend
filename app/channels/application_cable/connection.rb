# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token]

      api_token = ApiToken.active.find_by(token: token)

      reject_unauthorized_connection unless api_token

      api_token.user
    end
  end
end
