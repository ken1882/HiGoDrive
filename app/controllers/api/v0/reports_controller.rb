module Api
  module V0
    class ReportsController < ApplicationController
      include ReportsHelper
      before_action :validate_login
      before_action :set_report, only: [:show, :edit, :update, :destroy]
      before_action :set_task, only: [:index, :create]
      before_action :set_user
      before_action :validate_task
      before_action :validate_user, only: [:index, :show]

      # GET /tasks/:task_id/reviews
      def index
        render json: @task.reports.collect{|r| r.json_info}, status: :ok
      end

      # GET /tasks/:task_id/reviews/1
      def show
        render json: @report.json_info, status: :ok
      end

      # POST /reviews
      # POST /reviews.json
      def create
        _params = report_init_params
        _params[:id] = SecurityManager.md5("#{@user.id}@#{@task.id}")
        _params[:author_id] = @user.id
        puts SPLIT_LINE,_params[:id]
        begin
          @report = @task.reports.create(_params)
        rescue Mongo::Error::OperationFailure
          return bad_request("duplicated")
        end

        respond_to do |format|
          if @report.save
            return return_ok
          else
            return unprocessable_entity
          end
        end
      end
    
      private
      # Use callbacks to share common setup or constraints between actions.
      def set_report
        @report = Report.find(params[:id])
      end
      
      def set_task
        return @review.task if @review
        @task = Task.find params[:task_id].to_i
      end

      def set_user
        @user = current_user
      end

      def validate_login
        return unauthorized unless logged_in?
        return true
      end

      def validate_init_params
        _params = report_init_params
        _params[:comment] ||= ''
        return limit_excessed if _params[:comment].length > CommentLimit.last
        return bad_request("Too short") if _params[:comment].length < CommentLimit.first
        return true
      end

      def validate_task
        return not_found unless @task
        return true
      end

      def validate_user
        return unauthorized unless RoleManager.match?(@user.roles, :admin)
        return true
      end
    end
  end # Api::V0
end    