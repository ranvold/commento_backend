# frozen_string_literal: true

module Api
  module V1
    class MeController < ApplicationController
      def show
        render json: Current.user.as_json(only: %i[id username])
      end
    end
  end
end
