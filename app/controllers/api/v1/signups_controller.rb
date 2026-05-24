# frozen_string_literal: true

module Api
  module V1
    class SignupsController < ApplicationController
      allow_unauthenticated_access

      def create
        api_token = Users::Signup.call(params: signup_params)

        Current.user = api_token.user
        Current.api_token = api_token

        render json: { token: api_token.token }, status: :created
      end

      private

      def signup_params
        params.expect(signup: %i[username password])
      end
    end
  end
end
