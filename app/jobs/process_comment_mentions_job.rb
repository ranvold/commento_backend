# frozen_string_literal: true

class ProcessCommentMentionsJob < ApplicationJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.includes(:user).find(comment_id)

    Notifications::ProcessMentions.call(comment: comment)
  end
end
