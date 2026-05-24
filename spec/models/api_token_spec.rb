# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiToken, type: :model do
  describe "TOKEN_LIFETIME" do
    it "is 24 hours" do
      expect(ApiToken::TOKEN_LIFETIME).to eq(24.hours)
    end
  end

  describe "validations" do
    it "is invalid without a token" do
      token = build(:api_token)
      token.token = nil
      expect(token).not_to be_valid
    end

    it "is invalid with a duplicate token" do
      existing = create(:api_token)
      duplicate = build(:api_token, token: existing.token)
      expect(duplicate).not_to be_valid
    end
  end

  describe "expiration" do
    it "sets expires_at to approximately 24 hours from now on create" do
      token = create(:api_token)
      expect(token.expires_at).to be_within(5.seconds).of(24.hours.from_now)
    end

    it "does not override an explicitly provided expires_at" do
      custom_time = 1.hour.from_now
      token = create(:api_token, expires_at: custom_time)
      expect(token.expires_at).to be_within(1.second).of(custom_time)
    end
  end

  describe ".active scope" do
    let!(:active_token)  { create(:api_token, expires_at: 1.hour.from_now) }
    let!(:expired_token) { create(:api_token, expires_at: 1.hour.ago) }

    it "returns only non-expired tokens" do
      expect(described_class.active).to contain_exactly(active_token)
    end

    it "excludes expired tokens" do
      expect(described_class.active).not_to include(expired_token)
    end
  end
end
