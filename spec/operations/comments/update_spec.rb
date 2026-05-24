# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comments::Update do
  let(:author)  { create(:user) }
  let(:comment) { create(:comment, user: author, body: "Original body") }

  before { allow(ProcessCommentMentionsJob).to receive(:perform_later) }

  context "when the updated body contains mentions" do
    subject(:call) { described_class.call(comment: comment, params: { body: "Hello @alice" }) }

    it "updates the comment body" do
      call
      expect(comment.reload.body).to eq("Hello @alice")
    end

    it "enqueues the mention processing job" do
      call
      expect(ProcessCommentMentionsJob).to have_received(:perform_later).with(comment.id)
    end
  end

  context "when the updated body contains no mentions" do
    subject(:call) { described_class.call(comment: comment, params: { body: "No mentions" }) }

    it "updates the comment body" do
      call
      expect(comment.reload.body).to eq("No mentions")
    end

    it "does not enqueue the mention processing job" do
      call
      expect(ProcessCommentMentionsJob).not_to have_received(:perform_later)
    end
  end
end
