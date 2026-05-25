# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it "destroys api_tokens when user is destroyed" do
      user = create(:user)
      create(:api_token, user: user)
      expect { user.destroy }.to change(ApiToken, :count).by(-1)
    end

    it "destroys comments when user is destroyed" do
      user = create(:user)
      create(:comment, user: user)
      expect { user.destroy }.to change(Comment, :count).by(-1)
    end

    it "destroys notifications when recipient is destroyed" do
      user = create(:user)
      actor = create(:user)
      create(:notification, recipient: user, actor: actor)
      expect { user.destroy }.to change(Notification, :count).by(-1)
    end
  end

  describe "validations" do
    it "is invalid without a username" do
      user = build(:user, username: nil)
      expect(user).not_to be_valid
    end

    it "strips surrounding whitespace from the username before validation" do
      user = build(:user, username: "  alice  ")

      user.validate

      expect(user.username).to eq("alice")
    end

    it "is invalid with a duplicate username" do
      create(:user, username: "alice")
      user = build(:user, username: "alice")
      expect(user).not_to be_valid
    end

    it "is invalid with a duplicate username after normalization" do
      create(:user, username: "alice")
      user = build(:user, username: "  alice  ")

      expect(user).not_to be_valid
    end

    it "is invalid when the username contains spaces" do
      user = build(:user, username: "alice smith")

      user.validate

      expect(user.errors[:username]).to include("must be a single word without spaces or @")
    end

    it "is invalid when a new username contains @" do
      user = build(:user, username: "alice@smith")

      user.validate

      expect(user.errors[:username]).to include("must be a single word without spaces or @")
    end
  end
end
