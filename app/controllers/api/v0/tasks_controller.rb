module Api
  module V0
    class TasksController < ApplicationController
      include TasksHelper

      before_action :set_task, except: [:index, :create, :next_task]
      before_action :validate_login, except: [:index]
      before_action :validate_driver, only: [:accept, :reject, :engage,
        :finish]
      before_action :validate_timelock, only: [:create]
      before_action :validate_init_params, only: [:create]
      before_action :validate_status, only: [:accept, :reject, :engage, 
        :finish, :cancel]
      before_action :validate_rejections, only: [:reject]
      before_action :pick_mutex, only: [:accept]

      RejectReasonLimit = 100
      
      # Task picking mutex
      @@mutex   = Mutex.new

      # Task process mutex
      @@mutexes = 5.times.collect do
        mu = Mutex.new
        class << mu; attr_accessor :target; end
        mu
      end

      def self.create_task(user, _params)
        user = User.wide_query(user) unless user.is_a? User
        user.tasks.create(_params)
      end

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
        _params = task_init_params
        _params[:preorder] = _params[:preorder].to_i.to_bool
        if _params[:preorder]
          _driver = User.find(_params[:driver_id])
          return not_found unless _driver
          return forbidden unless _driver.licensed?
        end
        @task = TasksController.create_task(current_user, _params)
        respond_to do |format|
          if @task.save
            @task.driver.add_preorder(@task.id) if @task.preorder?
            format.html { redirect_to '/home', notice: 'Task was successfully created.' }
            format.json { render json: {message: 'created', id: @task.id}, status: :created}
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
        next_preorder = (@user.unaccepted_preorders || []).first

        ret_cur = 0; ret_nxt = 0;
        idx = (tid == 0 ? 0 : $task_queue.index(tid)) || 0
        ret_cur = $task_queue[idx]
        ret_nxt = $task_queue[idx+1]
        render json: {task_id: ret_cur || 0, next_id: ret_nxt || 0}
      end

      # POST /task/accept
      def accept
        return unprocessable_entity if @task.accepted?
        if @task.preorder?
          @task.accept(current_user.id)
        else
          @mutex.synchronize{
            @task.accept(current_user.id)
            @mutex.target = nil
          }
        end
        return_ok
      end

      # POST /task/reject
      def reject
        @task.reject(params[:reason])
        return_ok
      end

      # POST /task/engage
      def engage
        @task.engage 
        return_ok
      end

      # POST /task/finish
      def finish
        return unprocessable_entity unless @task.engaging?
        @task.finish
        return_ok
      end

      # POST /tasks/comment
      def send_comment
        return unprocessable_entity if @task.closed?
        target = nil
        target = @task.author if @user.id == @task.driver_id
        target = @task.driver_id if @user.id == @task.author_id
        return forbidden unless target
        PushNotificationsController.create_notification(target, params[:message]).send_message
        return_ok
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

      def validate_driver
        return forbidden unless current_user.licensed?
        return forbidden unless @task.driver.nil? || @task.driver != current_user.id
        return true
      end

      def validate_status
        return unprocessable_entity if @task.closed?
        return true
      end

      def validate_rejections
        strlen = (params[:reason] || '').length
        return unprocessable_entity if strlen == 0
        return limit_excessed if strlen > RejectReasonLimit
        return true
      end

      def pick_mutex
        return conflict if @@mutexes.any?{|m| m.target == @task.id}
        @mutex = nil
        timeout = 0
        # Pick idle mutex
        while @mutex.nil?
          @@mutex.synchronize{
            @@mutexes.each do |mu|
              next if mu.target
              mu.target = @task.id
              @mutex = mu
              break
            end
          }
          return overloaded if timeout >= AjaxTimeLimit
          timeout += 100
          sleep(0.1)
        end
      end

    end # controller
  end # V0
end # API