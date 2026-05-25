# frozen_string_literal: true

module Notifications
  class ProcessMentions
    extend Callable

    def call(comment:)
      usernames = comment.mentioned_usernames

      return if usernames.empty?

      recipients = User.where(username: usernames)

      Notifications::Create.call(comment: comment, recipients: recipients)
    end
  end
end
