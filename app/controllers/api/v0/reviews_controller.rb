module Api
  module V0
    class ReviewsController < ApplicationController
      include ReviewsHelper

      before_action :validate_login, except: [:index]
      before_action :set_review, only: [:show, :edit, :update, :destroy]
      before_action :set_task, only: [:index, :create]
      before_action :set_user, except: [:index]
      before_action :validate_task

      # GET /tasks/:task_id/reviews
      def index
        render json: @task.reviews.collect{|r| r.json_info}, status: :ok
      end

      # GET /tasks/:task_id/reviews/1
      def show
        return_wip
      end

      # POST /reviews
      # POST /reviews.json
      def create
        _params = review_init_param
        _params[:id] = SecurityManager.md5("#{@user.id}_#{@task.id}")
        _params[:score] = _params[:score].to_i
        _params[:author_id] = @user.id
        
        begin
          @review = @task.reviews.create(_params)
        rescue Mongo::Error::OperationFailure
          return bad_request("duplicated")
        end

        respond_to do |format|
          if @review.save
            return return_ok
          else
            return unprocessable_entity
          end
        end
      end

      private
      
      def set_review
        @review = Review.find(params[:id])
      end
    
      def set_task
        return @review.task if @review
        @task = Task.find params[:id].to_i
      end

      def set_user
        @user = current_user
      end

      def validate_login
        return unauthorized unless logged_in?
        return true
      end

      def validate_init_params
        _params = review_init_params
        _params[:comment] ||= ''
        _params[:score] = (_params[:score].to_i rescue 0)
        return limit_excessed if _params[:comment].length > CommentLimit
        return bad_request unless _params[:score].between?(1,5)
        return true
      end

      def validate_task
        return not_found unless @task
        return unprocessable_entity unless @task.closed?
        return true
      end
    end
  end # Api::V0
end