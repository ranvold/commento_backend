# frozen_string_literal: true

module Users
  class Login
    extend Callable

    def call(params:)
      user = User.find_by(username: params[:username])&.authenticate(params[:password])
      raise UnauthorizedError unless user

      user.api_tokens.create!
    end
  end
end
