# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comments::Destroy do
  subject(:call) { described_class.call(comment: comment) }

  let(:author)    { create(:user) }
  let(:recipient) { create(:user) }
  let(:comment)   { create(:comment, user: author) }

  before do
    comment
    allow(ActionCable.server).to receive(:broadcast)
  end

  it "destroys the comment" do
    expect { call }.to change(Comment, :count).by(-1)
  end

  context "when the comment has notifications" do
    before { create(:notification, recipient: recipient, actor: author, notifiable: comment) }

    it "destroys associated notifications" do
      expect { call }.to change(Notification, :count).by(-1)
    end

    it "broadcasts to each recipient after deletion" do
      call

      expect(ActionCable.server).to have_received(:broadcast).with(
        "users:#{recipient.id}:notifications",
        { type: NotificationBroadcast::TYPE }
      )
    end
  end

  context "when the comment has no notifications" do
    it "does not broadcast" do
      call

      expect(ActionCable.server).not_to have_received(:broadcast)
    end
  end
end
