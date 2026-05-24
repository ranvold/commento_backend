# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Notifications", type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { "Bearer #{create(:api_token, user: user).token}" }

  path "/api/v1/notifications" do
    get "Returns a paginated list of notifications" do
      tags "Notifications"
      produces "application/json"
      operationId "listNotifications"

      parameter name: "Authorization", in: :header, type: :string, required: true,
                description: "Bearer <token>"
      parameter name: :page, in: :query, type: :integer, required: false

      response "200", "notifications listed" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       actor_id: { type: :integer },
                       recipient_id: { type: :integer },
                       notifiable_id: { type: :integer },
                       notifiable_type: { type: :string },
                       kind: { type: :string },
                       read_at: { type: :string, nullable: true },
                       created_at: { type: :string },
                       updated_at: { type: :string },
                       actor: {
                         type: :object,
                         properties: { username: { type: :string } },
                         required: %w[username]
                       },
                       notifiable: {
                         type: :object,
                         properties: {
                           id: { type: :integer },
                           body: { type: :string },
                           created_at: { type: :string }
                         },
                         required: %w[id body created_at]
                       }
                     },
                     required: %w[id actor_id recipient_id kind created_at updated_at actor notifiable]
                   }
                 },
                 meta: { type: :object }
               },
               required: %w[data meta]

        context "when the user has notifications" do
          let(:page) { 1 }

          before do
            create(:notification, recipient: user)
            create(:notification) # another user's notification — must not appear
          end

          run_test! do |response|
            data = response.parsed_body
            expect(data["data"].length).to eq(1)
            expect(data["meta"]).to be_present
            expect(data["data"].first["actor"]).to include("username")
            expect(data["data"].first["notifiable"]).to include("id", "body", "created_at")
          end
        end
      end

      response "401", "missing or invalid token" do
        schema type: :object,
               properties: { message: { type: :string } },
               required: %w[message]

        let(:Authorization) { "Bearer invalid_token" }
        let(:page) { 1 }

        run_test! do |response|
          expect(response.parsed_body["message"]).to eq("Unauthorized")
        end
      end
    end
  end

  path "/api/v1/notifications/unread_count" do
    get "Returns the count of unread notifications" do
      tags "Notifications"
      produces "application/json"
      operationId "unreadNotificationsCount"

      parameter name: "Authorization", in: :header, type: :string, required: true,
                description: "Bearer <token>"

      response "200", "unread count returned" do
        schema type: :object,
               properties: { unread_count: { type: :integer } },
               required: %w[unread_count]

        context "when the user has read and unread notifications" do
          before do
            create(:notification, recipient: user, read_at: nil)
            create(:notification, recipient: user, read_at: nil)
            create(:notification, recipient: user, read_at: Time.current)
          end

          run_test! do |response|
            expect(response.parsed_body["unread_count"]).to eq(2)
          end
        end
      end

      response "401", "missing or invalid token" do
        schema type: :object,
               properties: { message: { type: :string } },
               required: %w[message]

        let(:Authorization) { "Bearer invalid_token" }

        run_test! do |response|
          expect(response.parsed_body["message"]).to eq("Unauthorized")
        end
      end
    end
  end

  path "/api/v1/notifications/mark_all_as_read" do
    patch "Marks all unread notifications as read" do
      tags "Notifications"
      operationId "markAllNotificationsAsRead"

      parameter name: "Authorization", in: :header, type: :string, required: true,
                description: "Bearer <token>"

      response "204", "all notifications marked as read" do
        context "when marking the current user's unread notifications" do
          before do
            create(:notification, recipient: user, read_at: nil)
            create(:notification, recipient: user, read_at: nil)
          end

          run_test! do
            expect(user.notifications.unread.count).to eq(0)
          end
        end

        context "when other users have unread notifications" do
          let!(:other_notification) { create(:notification, read_at: nil) }

          run_test! do
            expect(other_notification.reload.read_at).to be_nil
          end
        end
      end

      response "401", "missing or invalid token" do
        schema type: :object,
               properties: { message: { type: :string } },
               required: %w[message]

        let(:Authorization) { "Bearer invalid_token" }

        run_test! do |response|
          expect(response.parsed_body["message"]).to eq("Unauthorized")
        end
      end
    end
  end

  path "/api/v1/notifications/{id}/mark_as_read" do
    parameter name: :id, in: :path, type: :integer, required: true

    patch "Marks a notification as read" do
      tags "Notifications"
      operationId "markNotificationAsRead"

      parameter name: "Authorization", in: :header, type: :string, required: true,
                description: "Bearer <token>"

      response "204", "notification marked as read" do
        let(:notification) { create(:notification, recipient: user, read_at: nil) }
        let(:id) { notification.id }

        run_test! do
          expect(notification.reload.read_at).not_to be_nil
        end
      end

      response "401", "missing or invalid token" do
        schema type: :object,
               properties: { message: { type: :string } },
               required: %w[message]

        let(:notification) { create(:notification, recipient: user, read_at: nil) }
        let(:id) { notification.id }
        let(:Authorization) { "Bearer invalid_token" }

        run_test! do |response|
          expect(response.parsed_body["message"]).to eq("Unauthorized")
        end
      end

      response "403", "not the notification owner" do
        let(:other_user) { create(:user) }
        let(:notification) { create(:notification, recipient: other_user, read_at: nil) }
        let(:id) { notification.id }

        run_test!
      end
    end
  end
end
