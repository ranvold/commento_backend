# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :user
  attribute :api_token

  resets { Time.zone = "UTC" }
end
