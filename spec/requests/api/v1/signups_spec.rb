# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Signups", :aggregate_failures, type: :request do
  subject(:perform_request) { post "/api/v1/signup", params: request_params, as: :json }

  let(:request_params) { { username: "alice", password: "password123" } }

  describe "POST /api/v1/signup" do
    it "creates a user and an api token" do
      expect { perform_request }.to change(User, :count).by(1).and change(ApiToken, :count).by(1)
    end

    it "returns a created response with a token" do
      perform_request
      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to match("token" => a_kind_of(String))
    end

    it "returns a token for the created user" do
      perform_request
      created_api_token = ApiToken.active.find_by!(token: response.parsed_body.fetch("token"))
      expect(created_api_token.user.username).to eq("alice")
    end

    it "creates an api token with an expiration" do
      perform_request

      created_api_token = ApiToken.find_by!(token: response.parsed_body.fetch("token"))

      expect(created_api_token.expires_at).to be_within(5.seconds).of(ApiToken::TOKEN_LIFETIME.from_now)
    end

    context "when the username is already taken" do
      let(:expected_errors) { { "username" => ["has already been taken"] } }

      before { create(:user, username: "alice") }

      it "does not create a user" do
        expect { perform_request }.not_to change(User, :count)
      end

      it "returns validation errors" do
        perform_request
        expect_validation_errors(expected_errors)
      end
    end

    context "when required params are missing" do
      let(:request_params) { { username: "alice" } }
      let(:expected_errors) { { "password" => ["can't be blank"] } }

      it "does not create a user" do
        expect { perform_request }.not_to change(User, :count)
      end

      it "returns validation errors" do
        perform_request
        expect_validation_errors(expected_errors)
      end
    end

    context "when the payload is empty" do
      let(:request_params) { {} }
      let(:expected_errors) do
        {
          "username" => ["can't be blank"],
          "password" => ["can't be blank"]
        }
      end

      it "does not create a user" do
        expect { perform_request }.not_to change(User, :count)
      end

      it "returns validation errors for both fields" do
        perform_request
        expect_validation_errors(expected_errors)
      end
    end

    context "when both params are blank" do
      let(:request_params) { { username: "", password: "" } }
      let(:expected_errors) do
        {
          "username" => ["can't be blank"],
          "password" => ["can't be blank"]
        }
      end

      it "does not create a user" do
        expect { perform_request }.not_to change(User, :count)
      end

      it "returns validation errors for both fields" do
        perform_request
        expect_validation_errors(expected_errors)
      end
    end
  end

  def expect_validation_errors(expected_errors)
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to eq("message" => expected_errors)
  end
end
