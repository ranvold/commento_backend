# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comments::SearchQuery, type: :query do
  subject(:query) { described_class.new }

  describe "#call" do
    let!(:older_comment) { create(:comment, body: "Older comment", created_at: 2.days.ago) }
    let!(:newer_comment) { create(:comment, body: "Newer comment", created_at: 1.day.ago) }

    context "without a search query" do
      it "returns all comments ordered by created_at desc" do
        result = query.call

        expect(result.to_a).to eq([newer_comment, older_comment])
      end

      it "eager-loads users to prevent N+1 queries" do
        result = query.call.to_a
        count = 0
        ActiveSupport::Notifications.subscribed(->(*, **) { count += 1 }, "sql.active_record") { result.each { |c| c.user.username } }
        expect(count).to eq(0)
      end
    end

    context "with a search query" do
      let!(:matching_comment) { create(:comment, body: "Searchable text here") }

      it "includes matching comments (case-insensitive)" do
        result = query.call(query: "SEARCHABLE")

        expect(result).to include(matching_comment)
      end

      it "excludes non-matching comments" do
        result = query.call(query: "SEARCHABLE")

        expect(result).not_to include(older_comment, newer_comment)
      end

      it "sanitizes SQL LIKE wildcards in the query" do
        wildcard_comment = create(:comment, body: "anything")

        result = query.call(query: "%")

        expect(result).not_to include(wildcard_comment)
      end

      it "returns an empty relation when no comments match" do
        result = query.call(query: "no-match-xyz")

        expect(result).to be_empty
      end
    end

    context "when query is blank" do
      it "returns all comments" do
        result = query.call(query: "")

        expect(result.count).to eq(Comment.count)
      end
    end
  end
end
