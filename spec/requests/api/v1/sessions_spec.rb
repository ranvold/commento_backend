# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/v1/sessions", type: :request do
  path "/api/v1/session" do
    post "Creates a session and returns an API token" do
      tags "Sessions"
      consumes "application/json"
      produces "application/json"
      operationId "createSession"

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          session: {
            type: :object,
            properties: {
              username: { type: :string },
              password: { type: :string }
            },
            required: %w[username password]
          }
        },
        required: %w[session]
      }

      response "201", "session created" do
        schema type: :object,
               properties: {
                 token: { type: :string }
               },
               required: %w[token]

        let(:user) { create(:user, password: "s3cr3t!") }
        let(:credentials) { { session: { username: user.username, password: "s3cr3t!" } } }

        run_test! do |response|
          data = response.parsed_body
          expect(data["token"]).to be_present
        end
      end

      response "401", "invalid credentials" do
        schema type: :object,
               properties: {
                 message: { type: :string }
               },
               required: %w[message]

        let(:credentials) { { session: { username: "nobody", password: "wrong" } } }

        run_test! do |response|
          data = response.parsed_body
          expect(data["message"]).to eq("Unauthorized")
        end
      end
    end

    delete "Destroys the current session" do
      tags "Sessions"
      operationId "deleteSession"

      parameter name: "Authorization", in: :header, type: :string, required: true,
                description: "Bearer <token>"

      response "204", "session destroyed" do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{create(:api_token, user: user).token}" }

        run_test!
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
