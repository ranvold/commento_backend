# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/v1/signups", type: :request do
  path "/api/v1/signup" do
    post "Creates a user account and returns an API token" do
      tags "Signups"
      consumes "application/json"
      produces "application/json"
      operationId "createSignup"

      parameter name: :signup, in: :body, schema: {
        type: :object,
        properties: {
          signup: {
            type: :object,
            properties: {
              username: { type: :string },
              password: { type: :string }
            },
            required: %w[username password]
          }
        },
        required: %w[signup]
      }

      response "201", "account created" do
        schema type: :object,
               properties: {
                 token: { type: :string }
               },
               required: %w[token]

        let(:signup) { { signup: { username: "alice", password: "s3cr3t!" } } }

        run_test! do |response|
          data = response.parsed_body
          expect(data["token"]).to be_present
        end
      end

      response "422", "validation failed (e.g. username taken)" do
        schema type: :object,
               properties: {
                 message: { type: :string },
                 errors: {
                   type: :object,
                   properties: {
                     username: {
                       type: :array,
                       items: { type: :string }
                     }
                   },
                   additionalProperties: false
                 }
               },
               required: %w[message errors]

        before { create(:user, username: "alice") }

        let(:signup) { { signup: { username: "alice", password: "s3cr3t!" } } }

        run_test! do |response|
          data = response.parsed_body
          expect(data["message"]).to eq("Validation failed: Username has already been taken")
          expect(data.dig("errors", "username")).to be_present
        end
      end
    end
  end
end
