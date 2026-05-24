# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApplicationController
      allow_unauthenticated_access only: :create

      def create
        api_token = Users::Login.call(params: session_params)

        Current.user = api_token.user
        Current.api_token = api_token

        render json: { token: api_token.token }, status: :created
      end

      def destroy
        Current.api_token.destroy!

        head :no_content
      end

      private

      def session_params
        params.expect(session: %i[username password])
      end
    end
  end
end
