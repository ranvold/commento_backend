# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comments::Create do
  subject(:call) { described_class.call(params: { body: body }) }

  let(:author) { create(:user) }
  let(:body) { "Hello @alice" }

  before do
    Current.user = author
    allow(ProcessCommentMentionsJob).to receive(:perform_later)
  end

  after { Current.reset }

  it "creates a comment for the current user" do
    expect { call }.to change { author.comments.count }.by(1)
  end

  it "persists the comment body" do
    call
    expect(Comment.last.body).to eq(body)
  end

  context "when the body contains mentions" do
    it "enqueues the mention processing job" do
      call
      expect(ProcessCommentMentionsJob).to have_received(:perform_later).with(Comment.last.id)
    end
  end

  context "when the body contains no mentions" do
    let(:body) { "No mentions here" }

    it "does not enqueue the mention processing job" do
      call
      expect(ProcessCommentMentionsJob).not_to have_received(:perform_later)
    end
  end
end
