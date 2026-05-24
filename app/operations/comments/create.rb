# frozen_string_literal: true

module Comments
  class Create
    extend Callable

    def call(params:)
      @comment = Current.user.comments.create!(params)

      process_comment_mentions if comment.mentioned_usernames.any?
    end

    private

    attr_reader :comment

    def process_comment_mentions
      ProcessCommentMentionsJob.perform_later(comment.id)
    end
  end
end
