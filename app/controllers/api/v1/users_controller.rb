# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      def index
        users = Users::SearchQuery.new.call(query: search_params[:query])

        render json: { data: users.as_json(only: %i[id username]) }
      end

      private

      def search_params
        params.permit(:query)
      end
    end
  end
end
