# frozen_string_literal: true

module Users
  class Signup
    extend Callable

    def call(params:)
      User.transaction do
        user = User.create!(username: params[:username], password: params[:password])
        user.api_tokens.create!
      end
    end
  end
end
