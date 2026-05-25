# frozen_string_literal: true

module Api
  module V1
    class CommentsController < ApplicationController
      include Pagy::Method

      before_action :set_comment, only: %i[update destroy]
      before_action :authorize_owner!, only: %i[update destroy]

      def index
        pagy, comments = if use_meilisearch?
          search_comments_using_meilisearch
        else
          search_comments_using_active_record
        end

        render json: {
          data: comments.as_json(include: { user: { only: :username } }),
          meta: pagy.data_hash(data_keys: %i[previous page next pages count])
        }
      end

      def create
        Comments::Create.call(params: comment_params)
        head :created
      end

      def update
        Comments::Update.call(comment: @comment, params: comment_params)
        head :ok
      end

      def destroy
        Comments::Destroy.call(comment: @comment)
        head :no_content
      end

      private

      def set_comment
        @comment = Comment.find(params.require(:id))
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

      def use_meilisearch?
        search_params[:query].present? && Meilisearch::Rails.active?
      end

      def search_comments_using_meilisearch
        ms_search = Comment.pagy_search(search_params[:query], sort: ["created_at:desc"])
        pagy(:meilisearch, ms_search, page: search_params[:page].to_i)
      end

      def search_comments_using_active_record
        ar_search = Comments::SearchQuery.new.call(query: search_params[:query])
        pagy(ar_search, page: search_params[:page].to_i)
      end
    end
  end
end
