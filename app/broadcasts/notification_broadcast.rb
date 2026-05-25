# frozen_string_literal: true

class NotificationBroadcast
  TYPE = "mentioning"

  def self.call(recipient_id:)
    ActionCable.server.broadcast(
      "users:#{recipient_id}:notifications",
      {
        type: TYPE
      }
    )
  end
end
