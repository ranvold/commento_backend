# frozen_string_literal: true

module Comments
  class Destroy
    extend Callable

    def call(comment:)
      recipient_ids = comment.notifications.distinct.pluck(:recipient_id)

      comment.destroy!

      recipient_ids.each do |recipient_id|
        NotificationBroadcast.call(recipient_id: recipient_id)
      end
    end
  end
end
