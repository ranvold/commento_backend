# frozen_string_literal: true

class ProcessCommentMentionChangesJob < ApplicationJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.includes(:user).find(comment_id)

    Notifications::ProcessMentionChanges.call(comment: comment)
  end
end
