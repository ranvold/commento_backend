# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationBroadcast do
  describe ".call" do
    let(:recipient) { create(:user) }

    before { allow(ActionCable.server).to receive(:broadcast) }

    it "broadcasts to the recipient's notifications channel" do
      described_class.call(recipient_id: recipient.id)

      expect(ActionCable.server).to have_received(:broadcast).with(
        "users:#{recipient.id}:notifications",
        { type: NotificationBroadcast::TYPE }
      )
    end

    it "does not broadcast to any other channel" do
      described_class.call(recipient_id: recipient.id)

      expect(ActionCable.server).to have_received(:broadcast).once
    end
  end
end
