# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    recipient { association(:user) }
    actor { association(:user) }
    notifiable { association(:comment) }
    kind { :mention }
  end
end
