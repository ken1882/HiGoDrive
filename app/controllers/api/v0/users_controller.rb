module Api
  module V0
    class UsersController < ApplicationController
      include UsersHelper
      
      before_action :set_user, only: [:show, :getpos, :forgot_password,
        :reset_password, :peak]
      before_action :set_current_user, only: [:update, :setpos,
        :user_tasks, :tasks_engaging, :tasks_history]
      # ----------
      before_action :validate_init_params, only: [:create]
      before_action :validate_update_params, only: [:update]
      before_action :validate_forgotpwd_params, only: [:forgot_password]
      before_action :validate_resetpwd_params, only: [:reset_password]
      
      BioMaxLen = 2000

      # GET /users
      # GET /users.json
      def index
        render json: {size: User.count}, status: :ok
      end
    
      # GET /users/1
      # GET /users/1.json
      def show
        render json: @user.public_json_info, status: :ok
      end

      # GET /users/search/:username
      def peak
        render json: {uid: @user.id.to_s}, status: :ok
      end

      # POST /checkusername
      def checkusername
        _username = user_init_params[:username] || ''
        return bad_request unless _username.length.between?(3, 20)
        render json: {'message': User.username_exist?(_username)}
      end

      # POST /checkphone
      def checkphone
        number = Util.format_phone_number(params[:phone]) || ''
        return bad_request unless number.match(User::PhoneRegex)
        render json: {'message': User.phone_exist?(number)}
      end

      # POST /checkemail
      def checkemail
        _email = user_init_params[:email] || ''
        return bad_request unless _email.length.between?(3, 255)
        render json: {'message': User.email_exist?(_email)}
      end

      # POST /users
      # POST /users.json
      def create
        @user = User.new(user_init_params)
        respond_to do |format|
          if @user.save
            format.html { redirect_to '/', notice: 'User was successfully created.' }
            format.json { render json: {message: 'created'}, status: :created}
          else
            format.html { unprocessable_entity }
            format.json { render json: @user.errors, status: :unprocessable_entity }
          end
        end
      end
    
      # PATCH/PUT /users/1
      # PATCH/PUT /users/1.json
      def update
        @user.update(user_update_fields)
        return_ok
      end
    
      # DELETE /users/1
      # DELETE /users/1.json
      def destroy
        not_acceptable
      end

      # POST /user/setpos
      def setpos
        _params = user_pos_params
        lat, lng = _params[:lat], _params[:lng]
        return bad_request unless coordinates_ok?(lat, lng)
        @user.set_pos(lat, lng)
        return_ok
      end
      
      # GET /user/getpos
      def getpos
        render json: @user.get_pos, status: :ok
      end

      # POST /forgotpassword
      def forgot_password
        token = @user.generate_reset_token(params["authenticity_token"])
        return_ok
      end

      # POST /resetpassword
      # test
      def reset_password
        @user.reset_password(user_reset_fields)
        return_ok
      end

      # GET /mytasks
      def user_tasks
        render json: @user.tasks.collect{|t| t.id}, status: :ok
      end

      # GET /tasks_engaging
      def tasks_engaging
        render json: @user.tasks_engaging || [], status: :ok
      end

      # GET /tasks_engaging
      def tasks_history
        render json: @user.tasks_history || [], status: :ok
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = User.wide_query(user_find_params.compact.first)
        not_found if @user.nil?
      end

      def set_current_user
        @user = current_user
        unauthorized if @user.nil?
      end

      def validate_init_params
        return bad_request unless register_param_ok?(user_init_params)
        return forbidden unless Util.email_deliverable?(user_init_params[:email])
        return unprocessable_entity unless driver_licensed?
        return true
      end

      def validate_update_params
        return unauthorized if @user.nil?
        return unsupported_media_type unless avatar_url_ok?(params[:avatar_url])
        return unprocessable_entity unless password_change_ok?(params)
        return forbidden if (params[:bio] || '').length > BioMaxLen
        return true
      end

      def validate_resetpwd_params
        return bad_request if logged_in?
        return unauthorized if params[:token] != @user.password_reset_token
        return unprocessable_entity unless password_reset_ok?(_params)
        return true
      end

      def validate_forgotpwd_params
        return bad_request if logged_in?
        return unauthorized if @user.username != params[:username]
        return unauthorized if @user.email != params[:email]
        return true
      end

      def avatar_url_ok?(aurl)
        return true if aurl.nil?
        return SupportedAvatarFormat.include?(aurl.split('.').last.downcase)
      end

      def password_change_ok?(_params)
        oldpwd = _params[:old_password]
        newpwd = _params[:password]
        conpwd = _params[:password_confirmation]
        return true unless oldpwd || newpwd || conpwd
        return false if !newpwd || !conpwd
        return false if newpwd != conpwd
        return false unless @user.authenticate(oldpwd)
        return true
      end

      def password_reset_ok?(_params)
        newpwd = _params[:password]
        conpwd = _params[:password_confirmation]
        return false if !newpwd || !conpwd
        return false if newpwd != conpwd
        return true
      end

      def register_param_ok?(params)
        return false if UserInitParms.any?{|k| params[k].nil?}
        return true
      end

      def driver_licensed?
        return true unless RoleManager.match?(params[:roles].to_i, :driver)
        return @user.licensed?
      end

      def coordinates_ok?(lat, lng)
        x = Float(lng) rescue nil
        y = Float(lat) rescue nil
        return x && y
      end

      def user_url
        "/home"
      end

    end # class
  end
end