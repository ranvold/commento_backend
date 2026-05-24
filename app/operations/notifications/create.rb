# frozen_string_literal: true

module Notifications
  class Create
    extend Callable

    def call(comment:, recipients:)
      recipients.find_each do |recipient|
        next if recipient == comment.user

        notification = Notification.create!(
          recipient: recipient,
          actor: comment.user,
          notifiable: comment,
          kind: :mention
        )

        NotificationBroadcast.call(notification: notification)
      end
    end
  end
end
