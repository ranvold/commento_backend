# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Users", type: :request do
  path "/api/v1/users" do
    get "Returns a list of users" do
      tags "Users"
      produces "application/json"
      operationId "listUsers"

      parameter name: "Authorization", in: :header, type: :string, required: true,
                description: "Bearer <token>"
      parameter name: :query, in: :query, type: :string, required: false

      response "200", "users listed" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       username: { type: :string }
                     },
                     required: %w[id username]
                   }
                 }
               },
               required: %w[data]

        let!(:viewer) do
          create(:user, username: "viewer", created_at: 3.days.ago, updated_at: 3.days.ago)
        end
        let!(:api_token) { create(:api_token, user: viewer) }
        let(:Authorization) { "Bearer #{api_token.token}" }

        context "without a search query" do
          let!(:older_user) do
            create(:user, username: "older-user", created_at: 2.days.ago, updated_at: 2.days.ago)
          end
          let!(:newer_user) do
            create(:user, username: "newer-user", created_at: 1.day.ago, updated_at: 1.day.ago)
          end

          run_test! do |response|
            expect(response.parsed_body).to eq(
              "data" => [
                { "id" => newer_user.id, "username" => newer_user.username },
                { "id" => older_user.id, "username" => older_user.username },
                { "id" => viewer.id, "username" => viewer.username }
              ]
            )
          end
        end

        context "with a search query" do
          let(:query) { "SEARCH" }
          let!(:search_beta) { create(:user, username: "search-beta") }
          let!(:search_alpha) { create(:user, username: "search-alpha") }

          before do
            create(:user, username: "no-match")
          end

          run_test! do |response|
            expect(response.parsed_body).to eq(
              "data" => [
                { "id" => search_alpha.id, "username" => search_alpha.username },
                { "id" => search_beta.id, "username" => search_beta.username }
              ]
            )
          end
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
          expect(response.parsed_body["message"]).to eq("Unauthorized")
        end
      end
    end
  end
end
