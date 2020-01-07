module Api
  module V0
    class ReportsController < ApplicationController
      include ReportsHelper
      before_action :validate_login
      before_action :set_report, only: [:mark_finished, :edit, :update, :destroy]
      before_action :set_task, only: [:index, :create]
      before_action :set_user
      before_action :validate_task

      # GET /reports
      def index
        return unauthorized unless RoleManager.match?(@user.roles, :admin)
        ret = Report.all.collect do |re|
          next if re.finished?
          re.json_info
        end
        render json: ret, status: :ok
      end

      # GET /tasks/:task_id/reports
      def show
        if RoleManager.match?(@user.roles, :admin)
          render json: @task.reports.collect{|r| r.json_info}, status: :ok
        else
          reports = @task.reports
          idx  = reports.find_index{|r| r.author_id == @user.id}
          ret = idx.nil? ? nil : reports[idx].json_info
          render json: ret, status: :ok
        end
      end

      # POST /reports
      # POST /reports.json
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
      
      # POST /finish_report/:id
      def mark_finished
        return unauthorized unless RoleManager.match?(@user.roles, :admin)
        @report.update({:finished => true})
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
    end
  end # Api::V0
end    