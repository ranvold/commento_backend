# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::Login do
  describe ".call" do
    subject(:call) { described_class.call(params: { username: "alice", password: "s3cr3t!" }) }

    let!(:user) { create(:user, username: "alice", password: "s3cr3t!") }

    it "creates an api token for the user" do
      expect { call }.to change { user.api_tokens.count }.by(1)
    end

    it "returns the api token" do
      result = call
      expect(result).to be_a(ApiToken)
    end

    it "associates the token with the correct user" do
      token = call
      expect(token.user).to eq(user)
    end

    context "when the username does not exist" do
      subject(:call) { described_class.call(params: { username: "nobody", password: "s3cr3t!" }) }

      it "raises UnauthorizedError" do
        expect { call }.to raise_error(UnauthorizedError)
      end
    end

    context "when the password is wrong" do
      subject(:call) { described_class.call(params: { username: "alice", password: "wrong" }) }

      it "raises UnauthorizedError" do
        expect { call }.to raise_error(UnauthorizedError)
      end
    end
  end
end
