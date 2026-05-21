# frozen_string_literal: true

class Api::V1::CommentsController < ApplicationController
  include Pagy::Method

  before_action :set_comment, only: %i[update destroy]
  before_action :authorize_owner!, only: %i[update destroy]

  def index
    pagy, comments = if search_params[:query].present?
      ms_search = Comment.pagy_search(search_params[:query], sort: ["created_at:desc"])
      pagy(:meilisearch, ms_search, page: search_params[:page].to_i)
    else
      pagy(Comment.includes(:user).order(created_at: :desc), page: search_params[:page].to_i)
    end

    render json: {
      data: comments.as_json(include: { user: { only: :username } }),
      meta: pagy.data_hash(data_keys: %i[previous page next pages count])
    }
  end

  def create
    comment = Current.user.comments.build(comment_params)

    comment.save!
    render json: { comment: comment.as_json(include: { user: { only: :username } }) }, status: :created
  end

  def update
    @comment.update!(comment_params)
    render json: { comment: @comment.as_json(include: { user: { only: :username } }) }
  end

  def destroy
    @comment.destroy
    head :no_content
  end

  private

  def set_comment
    @comment = Comment.find(params.expect(:id))
  end

  def authorize_owner!
    head :forbidden unless @comment.user_id == Current.user.id
  end

  def comment_params
    params.expect(comment: [:body])
  end

  def search_params
    params.permit(:page, :query)
  end
end
