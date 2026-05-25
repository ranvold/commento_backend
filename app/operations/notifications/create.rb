# frozen_string_literal: true

module Notifications
  class Create
    extend Callable

    def call(comment:, recipients:)
      recipients.find_each do |recipient|
        next if recipient == comment.user

        notification = create_or_find_notification(recipient, comment)
        broadcast(notification) if notification.previously_new_record?
      end
    end

    private

    def create_or_find_notification(recipient, comment)
      Notification.create_or_find_by!(
        recipient: recipient,
        notifiable: comment
      ) do |notification|
        notification.actor = comment.user
        notification.kind = :mention
      end
    end

    def broadcast(notification)
      NotificationBroadcast.call(recipient_id: notification.recipient_id)
    end
  end
end
