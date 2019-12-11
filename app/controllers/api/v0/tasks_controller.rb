module Api
  module V0
    class TasksController < ApplicationController
      include TasksHelper

      before_action :set_task, only: [:show, :update, :destroy]

      before_action :validate_login, only: [:create, :update, :destroy,
        :next_task]
      before_action :validate_timelock, only: [:create]
      before_action :validate_init_params, only: [:create]
    
      # GET /tasks
      # GET /tasks.json
      def index
        render json: {size: Task.count}, status: :ok
      end
    
      # GET /tasks/1
      # GET /tasks/1.json
      def show
        render json: @task.public_json_info, status: :ok
      end

      # POST /tasks
      # POST /tasks.json
      def create
        @task = current_user.tasks.create(task_init_params)
        respond_to do |format|
          if @task.save
            format.html { redirect_to '/home', notice: 'Task was successfully created.' }
            format.json { render json: {message: 'created'}, status: :created}
          else
            format.html { unprocessable_entity }
            format.json { render json: @task.errors, status: :unprocessable_entity }
          end
        end
      end
    
      # PATCH/PUT /tasks/1
      # PATCH/PUT /tasks/1.json
      def update
        return return_wip
        respond_to do |format|
          if @task.update(task_params)
            format.html { redirect_to @task, notice: 'Task was successfully updated.' }
            format.json { render :show, status: :ok, location: @task }
          else
            format.html { render :edit }
            format.json { render json: @task.errors, status: :unprocessable_entity }
          end
        end
      end
    
      # DELETE /tasks/1
      # DELETE /tasks/1.json
      def destroy
        return return_wip
        @task.destroy
        respond_to do |format|
          format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
          format.json { head :no_content }
        end
      end
      

      # GET /next_task
      def next_task
        tid = params[:id].to_i rescue nil
        return bad_request if tid.nil?
        ret_cur = 0; ret_nxt = 0;
        idx = (tid == 0 ? 0 : $task_queue.index(tid)) || 0
        ret_cur = $task_queue[idx]
        ret_nxt = $task_queue[idx+1]
        render json: {task_id: ret_cur || 0, next_id: ret_nxt || 0}
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_task
        @task = Task.find(params[:id].to_i)
        return not_found unless @task
      end
    
      def validate_login
        return unauthorized unless logged_in?
        return true
      end
      
      def validate_timelock
        current_user.mutex.synchronize do
          lct = current_user.tasks.last.created_at.to_i rescue 0
          if (Time.now.to_i - lct).abs < 180
            return forbidden
          end
          return true
        end
      end

      def validate_init_params
        _time = params[:depart_time].to_i || 0
        curt  = Time.now.to_i
        return bad_request unless params[:dest].length.between?(1,256)
        return bad_request unless _time.between?(curt - 180, curt + 60 * 60 * 24 * 100)
        return true
      end

    end    
  end
end