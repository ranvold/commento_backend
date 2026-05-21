# frozen_string_literal: true

class Api::V1::SessionsController < ApplicationController
  allow_unauthenticated_access only: :create

  def create
    user = User.find_by(username: session_params[:username])&.authenticate(session_params[:password])

    raise UnauthorizedError unless user

    api_token = user.login!

    Current.user = api_token.user
    Current.api_token = api_token

    render json: { token: api_token.token }, status: :created
  end

  def destroy
    Current.api_token.destroy

    head :no_content
  end

  private

  def session_params
    params.expect(session: %i[username password])
  end
end
