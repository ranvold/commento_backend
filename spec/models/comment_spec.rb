# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comment, type: :model do
  describe "associations" do
    it "belongs to a user" do
      comment = build(:comment)
      expect(comment.user).to be_a(User)
    end

    it "destroys associated notifications when deleted" do
      comment = create(:comment)
      create(:notification, notifiable: comment)

      expect { comment.destroy }.to change(Notification, :count).by(-1)
    end
  end

  describe "validations" do
    it "is invalid without a body" do
      comment = build(:comment, body: nil)
      expect(comment).not_to be_valid
    end

    it "is valid with a body" do
      comment = build(:comment)
      expect(comment).to be_valid
    end
  end

  describe "#mentioned_usernames" do
    it "extracts mentioned usernames" do
      comment = build(:comment, body: "Hello @alice and @bob")
      expect(comment.mentioned_usernames).to eq(%w[alice bob])
    end

    it "returns unique usernames when the same handle appears multiple times" do
      comment = build(:comment, body: "@alice @alice")
      expect(comment.mentioned_usernames).to eq(["alice"])
    end

    it "returns an empty array when there are no mentions" do
      comment = build(:comment, body: "No mentions here")
      expect(comment.mentioned_usernames).to eq([])
    end

    it "returns an empty array for nil input" do
      comment = build(:comment, body: nil)
      expect(comment.mentioned_usernames).to eq([])
    end

    it "returns an empty array for an empty string" do
      comment = build(:comment, body: "")
      expect(comment.mentioned_usernames).to eq([])
    end

    it "handles usernames with underscores and numbers" do
      comment = build(:comment, body: "@user_1 and @user2")
      expect(comment.mentioned_usernames).to eq(%w[user_1 user2])
    end

    it "handles mixed-case usernames" do
      comment = build(:comment, body: "@Alice @BOB")
      expect(comment.mentioned_usernames).to eq(%w[Alice BOB])
    end
  end
end
