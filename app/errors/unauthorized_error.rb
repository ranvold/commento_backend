# frozen_string_literal: true

class UnauthorizedError < StandardError
   def initialize(msg = "Unauthorized")
     super
   end
end
