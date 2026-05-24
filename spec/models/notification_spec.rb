# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notification, type: :model do
  describe "associations" do
    it "belongs to a recipient user" do
      notification = build(:notification)
      expect(notification.recipient).to be_a(User)
    end

    it "belongs to an actor user" do
      notification = build(:notification)
      expect(notification.actor).to be_a(User)
    end

    it "belongs to a polymorphic notifiable" do
      notification = build(:notification)
      expect(notification.notifiable).to be_a(Comment)
    end
  end

  describe "enums" do
    it "defines the mention kind with value 0" do
      expect(described_class.kinds[:mention]).to eq(0)
    end
  end

  describe ".unread scope" do
    let!(:unread) { create(:notification, read_at: nil) }

    before { create(:notification, read_at: Time.current) }

    it "returns only unread notifications" do
      expect(described_class.unread).to contain_exactly(unread)
    end
  end

  describe "#mark_as_read!" do
    let(:notification) { create(:notification, read_at: nil) }

    it "sets read_at to approximately the current time" do
      before_mark = Time.current
      notification.mark_as_read!
      after_mark = Time.current
      expect(notification.reload.read_at).to be_between(before_mark, after_mark)
    end

    it "persists the change" do
      notification.mark_as_read!
      expect(notification.reload.read_at).not_to be_nil
    end
  end
end
