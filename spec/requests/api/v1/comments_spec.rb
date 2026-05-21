# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/v1/comments", type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { "Bearer #{create(:api_token, user: user).token}" }

  path "/api/v1/comments" do
    get "Returns a paginated list of comments" do
      tags "Comments"
      produces "application/json"
      operationId "listComments"

      parameter name: "Authorization", in: :header, type: :string, required: true,
                description: "Bearer <token>"
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :limit, in: :query, type: :integer, required: false
      parameter name: :query, in: :query, type: :string, required: false

      response "200", "comments listed" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       body: { type: :string },
                       user_id: { type: :integer },
                       created_at: { type: :string },
                       updated_at: { type: :string },
                       user: {
                         type: :object,
                         properties: {
                           username: { type: :string }
                         },
                         required: %w[username]
                       }
                     },
                     required: %w[id body user_id created_at updated_at user]
                   }
                 },
                 meta: { type: :object }
               },
               required: %w[data meta]

        let(:page) { 1 }
        let(:expected_comment_json) do
          comment_record.as_json(include: { user: { only: :username } })
        end

        context "without a search query" do
          before { create_list(:comment, 2, user: user) }

          let(:limit) { 10 }
          let(:comment_record) { Comment.order(created_at: :desc).first }

          run_test! do |response|
            data = response.parsed_body
            expect(data["data"].length).to eq(2)
            expect(data["meta"]).to be_present
          end
        end

        context "with a search query" do
          let(:query) { "search" }
          let(:comment_record) { create(:comment, user: user, body: "Searchable comment") }
          let(:meta) { { previous: nil, page: 1, next: nil, pages: 1, count: 1 } }
          let(:pagy_record) { instance_double(Pagy, data_hash: meta) }
          let(:search_results) { instance_double(Pagy::Search::Arguments) }

          before do
            comment_record

            allow(Comment).to receive(:pagy_search).with(query, sort: ["created_at:desc"]).and_return(search_results)
            allow(Api::V1::CommentsController).to receive(:new).and_wrap_original do |original, *args, &block|
              original.call(*args, &block).tap do |controller|
                allow(controller)
                  .to receive(:pagy)
                  .with(:meilisearch, search_results, page: page)
                  .and_return([pagy_record, [comment_record]])
              end
            end
          end

          run_test! do |response|
            expect(Comment).to have_received(:pagy_search).with(query, sort: ["created_at:desc"])
            expect(response.parsed_body).to eq(
              "data" => [expected_comment_json],
              "meta" => meta.stringify_keys
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
          data = response.parsed_body
          expect(data["message"]).to eq("Unauthorized")
        end
      end
    end

    post "Creates a comment" do
      tags "Comments"
      consumes "application/json"
      produces "application/json"
      operationId "createComment"

      parameter name: "Authorization", in: :header, type: :string, required: true,
                description: "Bearer <token>"

      parameter name: :comment, in: :body, schema: {
        type: :object,
        properties: {
          comment: {
            type: :object,
            properties: {
              body: { type: :string }
            },
            required: %w[body]
          }
        },
        required: %w[comment]
      }

      response "201", "comment created" do
        schema type: :object,
               properties: {
                 comment: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     body: { type: :string },
                     user_id: { type: :integer },
                     created_at: { type: :string },
                     updated_at: { type: :string },
                     user: {
                       type: :object,
                       properties: {
                         username: { type: :string }
                       },
                       required: %w[username]
                     }
                   },
                   required: %w[id body user_id created_at updated_at user]
                 }
               },
               required: %w[comment]

        let(:comment) { { comment: { body: "Great post!" } } }

        run_test! do |response|
          data = response.parsed_body
          expect(data.dig("comment", "body")).to eq("Great post!")
          expect(data.dig("comment", "user", "username")).to eq(user.username)
        end
      end

      response "401", "missing or invalid token" do
        schema type: :object,
               properties: {
                 message: { type: :string }
               },
               required: %w[message]

        let(:Authorization) { "Bearer invalid_token" }
        let(:comment) { { comment: { body: "Great post!" } } }

        run_test! do |response|
          data = response.parsed_body
          expect(data["message"]).to eq("Unauthorized")
        end
      end
    end
  end

  path "/api/v1/comments/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true

    patch "Updates a comment" do
      tags "Comments"
      consumes "application/json"
      produces "application/json"
      operationId "updateComment"

      parameter name: "Authorization", in: :header, type: :string, required: true,
                description: "Bearer <token>"

      parameter name: :comment, in: :body, schema: {
        type: :object,
        properties: {
          comment: {
            type: :object,
            properties: {
              body: { type: :string }
            },
            required: %w[body]
          }
        },
        required: %w[comment]
      }

      response "200", "comment updated" do
        schema type: :object,
               properties: {
                 comment: {
                   type: :object,
                   properties: {
                     id: { type: :integer },
                     body: { type: :string },
                     user_id: { type: :integer },
                     created_at: { type: :string },
                     updated_at: { type: :string },
                     user: {
                       type: :object,
                       properties: {
                         username: { type: :string }
                       },
                       required: %w[username]
                     }
                   },
                   required: %w[id body user_id created_at updated_at user]
                 }
               },
               required: %w[comment]

        let(:existing_comment) { create(:comment, user: user, body: "Original") }
        let(:id) { existing_comment.id }
        let(:comment) { { comment: { body: "Updated" } } }

        run_test! do |response|
          data = response.parsed_body
          expect(data.dig("comment", "body")).to eq("Updated")
        end
      end

      response "401", "missing or invalid token" do
        schema type: :object,
               properties: {
                 message: { type: :string }
               },
               required: %w[message]

        let(:existing_comment) { create(:comment, user: user) }
        let(:id) { existing_comment.id }
        let(:Authorization) { "Bearer invalid_token" }
        let(:comment) { { comment: { body: "Updated" } } }

        run_test! do |response|
          data = response.parsed_body
          expect(data["message"]).to eq("Unauthorized")
        end
      end

      response "403", "not the comment owner" do
        let(:other_user) { create(:user) }
        let(:existing_comment) { create(:comment, user: other_user) }
        let(:id) { existing_comment.id }
        let(:comment) { { comment: { body: "Updated" } } }

        run_test!
      end
    end

    delete "Destroys a comment" do
      tags "Comments"
      operationId "deleteComment"

      parameter name: "Authorization", in: :header, type: :string, required: true,
                description: "Bearer <token>"

      response "204", "comment deleted" do
        let(:existing_comment) { create(:comment, user: user) }
        let(:id) { existing_comment.id }

        run_test!
      end

      response "401", "missing or invalid token" do
        schema type: :object,
               properties: {
                 message: { type: :string }
               },
               required: %w[message]

        let(:existing_comment) { create(:comment, user: user) }
        let(:id) { existing_comment.id }
        let(:Authorization) { "Bearer invalid_token" }

        run_test! do |response|
          data = response.parsed_body
          expect(data["message"]).to eq("Unauthorized")
        end
      end

      response "403", "not the comment owner" do
        let(:other_user) { create(:user) }
        let(:existing_comment) { create(:comment, user: other_user) }
        let(:id) { existing_comment.id }

        run_test!
      end
    end
  end
end
