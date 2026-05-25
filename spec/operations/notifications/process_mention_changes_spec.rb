# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::ProcessMentionChanges do
  subject(:call) { described_class.call(comment: comment) }

  let(:author) { create(:user, username: "author") }

  before { allow(NotificationBroadcast).to receive(:call) }

  context "when mentions are added and removed" do
    let(:comment) { create(:comment, user: author, body: "Hello @kept @added") }
    let(:users) do
      {
        kept: create(:user, username: "kept"),
        added: create(:user, username: "added"),
        removed: create(:user, username: "removed")
      }
    end
    let(:existing_notifications) do
      {
        kept: create(
          :notification,
          recipient: users[:kept],
          actor: author,
          notifiable: comment
        ),
        removed: create(
          :notification,
          recipient: users[:removed],
          actor: author,
          notifiable: comment
        )
      }
    end

    before { existing_notifications }

    it "creates notifications for newly mentioned users" do
      expect { call }.to change {
        Notification.where(recipient: users[:added], notifiable: comment).count
      }.from(0).to(1)
    end

    it "removes notifications for users who are no longer mentioned" do
      call

      expect(Notification.exists?(id: existing_notifications[:removed].id)).to be(false)
    end

    it "keeps notifications for users who are still mentioned" do
      call

      expect(Notification.exists?(id: existing_notifications[:kept].id)).to be(true)
    end

    it "broadcasts newly added users once" do
      call

      expect(NotificationBroadcast).to have_received(:call).with(recipient_id: users[:added].id).once
    end

    it "broadcasts removed users once" do
      call

      expect(NotificationBroadcast).to have_received(:call).with(recipient_id: users[:removed].id).once
    end

    it "broadcasts unchanged users once" do
      call

      expect(NotificationBroadcast).to have_received(:call).with(recipient_id: users[:kept].id).once
    end
  end

  context "when mentions do not change" do
    let(:comment) { create(:comment, user: author, body: "Hello @kept") }
    let(:kept_user) { create(:user, username: "kept") }

    before do
      create(:notification, recipient: kept_user, actor: author, notifiable: comment)
    end

    it "does not change the notification count" do
      expect { call }.not_to change(Notification, :count)
    end

    it "broadcasts existing mention users once" do
      call

      expect(NotificationBroadcast).to have_received(:call).with(recipient_id: kept_user.id).once
    end
  end
end
