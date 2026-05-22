# frozen_string_literal: true

class Api::V1::UsersController < ApplicationController
  def index
    users = if search_params[:query].present?
      User.where("username ILIKE ?", "%#{search_params[:query]}%").order(username: :asc).limit(32)
    else
      User.order(created_at: :desc).limit(64)
    end

    render json: { data: users.as_json(only: %i[id username]) }
  end

  private

  def search_params
    params.permit(:query)
  end
end
