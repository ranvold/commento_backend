# frozen_string_literal: true

class NotificationBroadcast
  def self.call(notification:)
    ActionCable.server.broadcast(
      "users:#{notification.recipient_id}:notifications",
      {
        type: "notification_created"
      }
    )
  end
end
