# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/v1/me", type: :request do
  path "/api/v1/me" do
    get "Returns the current authenticated user" do
      tags "Users"
      produces "application/json"
      operationId "showCurrentUser"

      parameter name: "Authorization", in: :header, type: :string, required: true,
                description: "Bearer <token>"

      response "200", "current user returned" do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 username: { type: :string }
               },
               required: %w[id username]

        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{create(:api_token, user: user).token}" }

        run_test! do |response|
          data = response.parsed_body

          expect(data).to include(
            "id" => user.id,
            "username" => user.username
          )
        end
      end

      response "401", "missing or invalid token" do
        schema type: :object,
               properties: {
                 message: { type: :string }
               },
               required: %w[message]

        let(:Authorization) { "Bearer invalid_token" }

        run_test! do |response|
          data = response.parsed_body
          expect(data["message"]).to eq("Unauthorized")
        end
      end
    end
  end
end
