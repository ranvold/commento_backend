# frozen_string_literal: true

module Comments
  class Update
    extend Callable

    def call(comment:, params:)
      @comment = comment

      comment.update!(params)

      process_comment_mentions if comment.mentioned_usernames.any?
    end

    private

    attr_reader :comment

    def process_comment_mentions
      ProcessCommentMentionsJob.perform_later(comment.id)
    end
  end
end
