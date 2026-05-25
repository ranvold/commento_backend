# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProcessCommentMentionChangesJob, type: :job do
  subject(:perform_job) { described_class.perform_now(comment.id) }

  let(:comment) { create(:comment) }

  before do
    allow(Notifications::ProcessMentionChanges).to receive(:call)
  end

  it "processes mention changes for the comment" do
    perform_job

    expect(Notifications::ProcessMentionChanges).to have_received(:call).with(
      comment: an_object_having_attributes(id: comment.id)
    )
  end
end
