# frozen_string_literal: true

class Api::V1::MeController < ApplicationController
  def show
    render json: Current.user.as_json(only: %i[id username])
  end
end
