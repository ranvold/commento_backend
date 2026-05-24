# frozen_string_literal: true

module Api
  module V1
    class NotificationsController < ApplicationController
      include Pagy::Method

      before_action :set_notifications, only: %i[index unread_count mark_all_as_read]
      before_action :set_notification, only: :mark_as_read
      before_action :authorize_owner!, only: :mark_as_read

      def index
        scope = @notifications.includes(:actor, :notifiable).order(read_at: :desc, created_at: :asc)
        pagy, notifications = pagy(scope, page: params.permit(:page)[:page].to_i)

        render json: {
          data: notifications.as_json(include: { actor: { only: :username },
                                                 notifiable: { only: %i[id body created_at] } }),
          meta: pagy.data_hash(data_keys: %i[previous page next pages count])
        }
      end

      def unread_count
        render json: { unread_count: @notifications.unread.count }
      end

      def mark_as_read
        @notification.mark_as_read!
        head :no_content
      end

      def mark_all_as_read
        @notifications.unread.update_all(read_at: Time.current)
        head :no_content
      end

      private

      def set_notification
        @notification = Notification.find(params.require(:id))
      end

      def authorize_owner!
        head :forbidden unless @notification.recipient_id == Current.user.id
      end

      def set_notifications
        @notifications = Current.user.notifications
      end
    end
  end
end
