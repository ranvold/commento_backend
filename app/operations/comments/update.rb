# frozen_string_literal: true

module Comments
  class Update
    extend Callable

    def call(comment:, params:)
      @comment = comment

      comment.update!(params)

      process_comment_mention_changes if mention_changes?
    end

    private

    attr_reader :comment

    def process_comment_mention_changes
      ProcessCommentMentionChangesJob.perform_later(comment.id)
    end

    def mention_changes?
      comment.mentioned_usernames.any? || comment.notifications.mention.exists?
    end
  end
end
