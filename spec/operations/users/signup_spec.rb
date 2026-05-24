# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::Signup do
  describe ".call" do
    subject(:call) { described_class.call(params: { username: "alice", password: "s3cr3t!" }) }

    it "creates a new user" do
      expect { call }.to change(User, :count).by(1)
    end

    it "creates an api token for the user" do
      expect { call }.to change(ApiToken, :count).by(1)
    end

    it "returns the api token" do
      result = call
      expect(result).to be_a(ApiToken)
    end

    it "associates the token with the correct user" do
      token = call
      expect(token.user.username).to eq("alice")
    end

    context "when the username is already taken" do
      before { create(:user, username: "alice") }

      it "raises ActiveRecord::RecordInvalid" do
        expect { call }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "does not create a user" do
        expect do
          call
        rescue StandardError
          nil
        end.not_to change(User, :count)
      end

      it "does not create an api token" do
        expect do
          call
        rescue StandardError
          nil
        end.not_to change(ApiToken, :count)
      end
    end
  end
end
