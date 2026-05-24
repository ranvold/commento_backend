# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::SearchQuery, type: :query do
  subject(:query) { described_class.new }

  describe "#call" do
    let!(:older_user) { create(:user, username: "older-user", created_at: 2.days.ago) }
    let!(:newer_user) { create(:user, username: "newer-user", created_at: 1.day.ago) }

    context "without a search query" do
      it "returns users ordered by created_at desc" do
        result = query.call

        expect(result.to_a).to eq([newer_user, older_user])
      end

      it "limits results to DEFAULT_LIMIT" do
        expect(query.call.limit_value).to eq(Users::SearchQuery::DEFAULT_LIMIT)
      end
    end

    context "with a search query" do
      let!(:search_alpha) { create(:user, username: "search-alpha") }
      let!(:search_beta)  { create(:user, username: "search-beta") }

      before { create(:user, username: "no-match") }

      it "returns only users matching the query (case-insensitive)" do
        result = query.call(query: "SEARCH")

        expect(result.to_a).to eq([search_alpha, search_beta])
      end

      it "orders results by username asc" do
        result = query.call(query: "search")

        expect(result.map(&:username)).to eq(%w[search-alpha search-beta])
      end

      it "limits results to SEARCH_LIMIT" do
        expect(query.call(query: "search").limit_value).to eq(Users::SearchQuery::SEARCH_LIMIT)
      end

      it "sanitizes SQL LIKE wildcards in the query" do
        result = query.call(query: "%")

        expect(result).to be_empty
      end

      it "returns an empty relation when no users match" do
        result = query.call(query: "no-match-xyz")

        expect(result).to be_empty
      end
    end

    context "when query is blank" do
      it "returns all users without filtering" do
        result = query.call(query: "")

        expect(result.count).to eq(User.count)
      end
    end
  end
end
