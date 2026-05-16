# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Sessions", :aggregate_failures, type: :request do
  describe "POST /api/v1/session" do
    subject(:perform_request) { post "/api/v1/session", params: request_params, as: :json }

    let(:request_params) { { username: "alice", password: "password123" } }

    before { create(:user, username: "alice", password: "password123") }

    it "creates an api token" do
      expect { perform_request }.to change(ApiToken, :count).by(1)
    end

    it "returns a created response with a token" do
      perform_request

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to match("token" => a_kind_of(String))
    end

    it "returns a token for the existing user" do
      perform_request

      created_api_token = ApiToken.active.find_by!(token: response.parsed_body.fetch("token"))

      expect(created_api_token.user.username).to eq("alice")
    end

    it "creates an api token with an expiration" do
      perform_request

      created_api_token = ApiToken.find_by!(token: response.parsed_body.fetch("token"))

      expect(created_api_token.expires_at).to be_within(5.seconds).of(ApiToken::TOKEN_LIFETIME.from_now)
    end

    context "when the user already has an api token" do
      let(:user) { User.find_by!(username: "alice") }
      let!(:previous_api_token) { create(:api_token, user: user) }

      it "creates an additional api token for the user" do
        expect { perform_request }.to change(ApiToken, :count).by(1)

        expect(ApiToken.exists?(previous_api_token.id)).to be(true)
        expect(ApiToken.where(user: user).count).to eq(2)
      end
    end

    context "when credentials are invalid" do
      let(:request_params) { { username: "alice", password: "wrong-password" } }

      it "does not create an api token" do
        expect { perform_request }.not_to change(ApiToken, :count)
      end

      it "returns unauthorized" do
        perform_request

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to eq("message" => "Unauthorized")
      end
    end
  end

  describe "DELETE /api/v1/session" do
    subject(:perform_request) { delete "/api/v1/session", headers: headers }

    let(:user) { create(:user) }
    let!(:current_api_token) { create(:api_token, user: user) }
    let!(:other_api_token) { create(:api_token, user: user) }
    let(:headers) { { "Authorization" => "Bearer #{current_api_token.token}" } }

    it "destroys only the current api token" do
      expect { perform_request }.to change(ApiToken, :count).by(-1)

      expect(ApiToken.exists?(current_api_token.id)).to be(false)
      expect(ApiToken.exists?(other_api_token.id)).to be(true)
    end

    it "returns no content" do
      perform_request

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_blank
    end

    it "accepts credentials encoded with the Rails HTTP token helper" do
      helper_headers = {
        "Authorization" => ActionController::HttpAuthentication::Token.encode_credentials(current_api_token.token)
      }

      delete "/api/v1/session", headers: helper_headers

      expect(response).to have_http_status(:no_content)
    end

    context "when the api token is expired" do
      let!(:current_api_token) { create(:api_token, user: user, expires_at: 1.second.ago) }
      let!(:other_api_token) { create(:api_token, user: user) }

      it "returns unauthorized" do
        perform_request

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to eq("message" => "Unauthorized")
      end

      it "does not destroy any api tokens" do
        expect { perform_request }.not_to change(ApiToken, :count)
      end
    end

    context "when the user has multiple active api tokens" do
      let(:user) { create(:user, username: "alice", password: "password123") }
      let!(:previous_api_token) { create(:api_token, user: user) }

      before do
        post "/api/v1/session", params: { username: "alice", password: "password123" }, as: :json
      end

      it "keeps the other api token active after logout" do
        current_api_token = ApiToken.find_by!(token: response.parsed_body.fetch("token"))
        delete "/api/v1/session", headers: { "Authorization" => "Bearer #{previous_api_token.token}" }

        expect(response).to have_http_status(:no_content)
        expect(ApiToken.where(id: [previous_api_token.id,
                                   current_api_token.id]).pluck(:id)).to contain_exactly(current_api_token.id)
      end
    end

    context "when the request is unauthenticated" do
      let(:headers) { {} }

      it "does not destroy an api token" do
        expect { perform_request }.not_to change(ApiToken, :count)
      end

      it "returns unauthorized" do
        perform_request

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to eq("message" => "Unauthorized")
      end
    end
  end
end
