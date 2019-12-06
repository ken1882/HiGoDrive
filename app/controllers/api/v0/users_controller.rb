module Api
  module V0
    class UsersController < ApplicationController
      include UsersHelper
      
      before_action :set_user, only: [:show, :edit, :update, :login]
      before_action :validate_init_params, only: [:create]
      before_action :validate_update_params, only: [:update]

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
      
      # POST /checkusername
      def checkusername
        _username = user_init_params[:username] || ''
        return unprocessable_entity unless _username.length.between?(3, 20)
        render json: {'message': User.username_exist?(_username)}
      end

      # POST /checkemail
      def checkemail
        _email = user_init_params[:email] || ''
        return unprocessable_entity unless _email.length.between?(3, 255)
        render json: {'message': User.email_exist?(_email)}
      end

      # POST /users
      # POST /users.json
      def create
        @user = User.new(user_init_params)
        respond_to do |format|
          if @user.save
            format.html { redirect_to user_url, notice: 'User was successfully created.' }
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

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_user
        @user = current_user || User.wide_query(user_find_params.compact.first)
        not_found if @user.nil?
      end

      def validate_init_params
        respond_msg = nil
        respond_msg = "The information you entered is invalid" unless register_param_ok?(user_init_params)
        respond_msg = "Undeliverable Email" unless Util.email_deliverable?(user_init_params[:email])
        return true unless respond_msg
        respond_to do |f|
          f.html {
            flash[:danger] = respond_msg
            redirect_to root_path
          }
          f.json {render json: {'message' => respond_msg}, status: :unprocessable_entity}
        end
      end

      def validate_update_params
        _params = user_update_params
        return unauthorized if @user.nil?
        return unsupported_media_type unless avatar_url_ok?(_params[:avatar_url])
        return unprocessable_entity unless password_change_ok?(_params)
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
        return false if newpwd != conpwd
        return false unless @user.authenticate(oldpwd)
        return true
      end

      def register_param_ok?(params)
        return false if User.exist?(params)
        return false if (params[:password] || '').length < 6
        return false unless params[:username].match(/^[[:alnum:]]*$/)
        return true
      end

      def user_url
        "/user/#{@user.username}"
      end

    end # class
  end
end