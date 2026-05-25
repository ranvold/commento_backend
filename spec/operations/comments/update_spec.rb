# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comments::Update do
  let(:author)  { create(:user) }
  let(:comment) { create(:comment, user: author, body: "Original body") }

  before { allow(ProcessCommentMentionChangesJob).to receive(:perform_later) }

  context "when the updated body contains mentions" do
    subject(:call) { described_class.call(comment: comment, params: { body: "Hello @alice" }) }

    it "updates the comment body" do
      call
      expect(comment.reload.body).to eq("Hello @alice")
    end

    it "enqueues the mention processing job" do
      call
      expect(ProcessCommentMentionChangesJob).to have_received(:perform_later).with(comment.id)
    end
  end

  context "when the updated body contains no mentions and there are no existing mention notifications" do
    subject(:call) { described_class.call(comment: comment, params: { body: "No mentions" }) }

    it "updates the comment body" do
      call
      expect(comment.reload.body).to eq("No mentions")
    end

    it "does not enqueue the mention change processing job" do
      call
      expect(ProcessCommentMentionChangesJob).not_to have_received(:perform_later)
    end
  end

  context "when the updated body removes existing mentions" do
    subject(:call) { described_class.call(comment: comment, params: { body: "No mentions" }) }

    let(:mentioned_user) { create(:user) }

    before do
      create(:notification, recipient: mentioned_user, actor: author, notifiable: comment)
    end

    it "enqueues the mention change processing job" do
      call

      expect(ProcessCommentMentionChangesJob).to have_received(:perform_later).with(comment.id)
    end
  end
end
