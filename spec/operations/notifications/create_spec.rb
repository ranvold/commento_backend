# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::Create do
  subject(:call) { described_class.call(comment: comment, recipients: recipients) }

  let(:author)    { create(:user) }
  let(:recipient) { create(:user) }
  let(:comment)   { create(:comment, user: author) }

  before { allow(ActionCable.server).to receive(:broadcast) }

  context "when recipients include users other than the author" do
    let(:recipients) { User.where(id: [author.id, recipient.id]) }

    it "creates a notification for each recipient who is not the author" do
      expect { call }.to change(Notification, :count).by(1)
    end

    it "sets the correct notification attributes" do
      call
      expect(Notification.last).to have_attributes(
        recipient: recipient, actor: author, notifiable: comment, kind: "mention"
      )
    end

    it "broadcasts a notification for the recipient" do
      call
      expect(ActionCable.server).to have_received(:broadcast).with(
        "users:#{recipient.id}:notifications",
        { type: NotificationBroadcast::TYPE }
      )
    end

    it "does not create a notification for the author" do
      call
      expect(Notification.where(recipient: author)).to be_empty
    end
  end

  context "when all recipients are the comment author" do
    let(:recipients) { User.where(id: author.id) }

    it "creates no notifications" do
      expect { call }.not_to change(Notification, :count)
    end
  end

  context "when there are no recipients" do
    let(:recipients) { User.none }

    it "creates no notifications" do
      expect { call }.not_to change(Notification, :count)
    end
  end

  context "when a notification already exists for the recipient and comment" do
    let(:recipients) { User.where(id: recipient.id) }

    before do
      create(:notification, recipient: recipient, actor: author, notifiable: comment)
    end

    it "does not create a duplicate notification" do
      expect { call }.not_to change(Notification, :count)
    end

    it "does not broadcast again" do
      call

      expect(ActionCable.server).not_to have_received(:broadcast)
    end
  end
end
