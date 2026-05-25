# frozen_string_literal: true

class AddUniqueIndexToNotificationsOnRecipientAndNotifiable < ActiveRecord::Migration[8.1]
  def change
    add_index :notifications,
              %i[recipient_id notifiable_type notifiable_id],
              unique: true,
              name: :index_notifications_on_recipient_and_notifiable
  end
end
