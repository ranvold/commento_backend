# frozen_string_literal: true

class Api::V1::SignupsController < ApplicationController
  allow_unauthenticated_access

  def create
    user = User.new(signup_params)

    api_token = user.signup!

    Current.user = api_token.user
    Current.api_token = api_token

    render json: { token: api_token.token }, status: :created
  end

  private

  def signup_params
    params.permit(:username, :password)
  end
end
