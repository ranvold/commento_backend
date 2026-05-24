# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::ProcessMentions do
  subject(:call) { described_class.call(comment: comment) }

  let(:author)         { create(:user, username: "author") }
  let(:mentioned_user) { create(:user, username: "alice") }

  before { allow(ActionCable.server).to receive(:broadcast) }

  context "when the comment body contains mentions" do
    let(:comment) { create(:comment, user: author, body: "Hello @alice") }

    before { mentioned_user }

    it "creates a notification for the mentioned user" do
      expect { call }.to change(Notification, :count).by(1)
    end

    it "sets the correct recipient on the notification" do
      call
      expect(Notification.last.recipient).to eq(mentioned_user)
    end

    it "sets the correct actor on the notification" do
      call
      expect(Notification.last.actor).to eq(author)
    end
  end

  context "when the comment body has no mentions" do
    let(:comment) { create(:comment, user: author, body: "No mentions here") }

    it "creates no notifications" do
      expect { call }.not_to change(Notification, :count)
    end
  end

  context "when the only mention is the comment author themselves" do
    let(:comment) { create(:comment, user: author, body: "Hello @author") }

    it "creates no notifications" do
      expect { call }.not_to change(Notification, :count)
    end
  end
end
