# frozen_string_literal: true

module AuthHelpers
  def authenticate!(user)
    api_token = create(:api_token, user: user)

    { "Authorization" => "Bearer #{api_token.token}" }
  end
end

RSpec.configure do |config|
  config.extend AuthHelpers, type: :request
end
