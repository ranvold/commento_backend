# frozen_string_literal: true

module Notifications
  class ProcessMentionChanges
    extend Callable

    def call(comment:)
      @comment = comment
      @detected_mentions_user_ids = User.where(username: comment.mentioned_usernames).pluck(:id)
      @existing_mentions_user_ids = comment.notifications.mention.distinct.pluck(:recipient_id)

      create_new_notifications
      delete_unnecessary_notifications
      broadcast_changes
    end

    private

    attr_reader :comment, :detected_mentions_user_ids, :existing_mentions_user_ids

    def create_new_notifications
      Notifications::Create.call(comment: comment, recipients: User.where(id: added_mentions_user_ids))
    end

    def delete_unnecessary_notifications
      comment.notifications.mention.where(recipient_id: removed_mentions_user_ids).destroy_all
    end

    def broadcast_changes
      existing_mentions_user_ids.each do |recipient_id|
        NotificationBroadcast.call(recipient_id: recipient_id)
      end
    end

    def added_mentions_user_ids
      @added_mentions_user_ids ||= detected_mentions_user_ids - existing_mentions_user_ids
    end

    def removed_mentions_user_ids
      @removed_mentions_user_ids ||= existing_mentions_user_ids - detected_mentions_user_ids
    end
  end
end
