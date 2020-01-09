module Api
  module V0
    class SessionController < ApplicationController
      LoginParams = [:username_or_email, :password, :remember_me]

      def new
        render "session/new"
      end

      def create
        log_out if logged_in?
        user = log_in(_params[:username_or_email], _params[:password])
        set_user(user)
        if logged_in?
          login_params[:remember_me] == '1' ? remember(user) : forget(user)
          respond_to do |f|
            f.html {redirect_to root_path}
            f.json {render json: {'message' => true}, status: :ok}
          end
        else
          respond_to do |f|
            f.html {
              flash.now[:danger] = 'Invalid username/email/password combination'
              render 'pages/login'
            }
            f.json {render json: {'message' => false}, status: :ok}
          end
        end
      end

      def destroy
        if logged_in?
          log_out
          notice_msg = "You have logged out successfully"
          json_msg = 'true'
        else
          notice_msg = "You haven't logged in yet"
          json_msg = 'false'
        end
        respond_to do |f|
          f.html {
            flash[:danger] = notice_msg
            redirect_to root_path
          }
          f.json {render json: {'message' => json_msg}, status: :ok}
        end
      end

      def index
        render json: {:uid => current_user.id.to_s}
      end

      private
      def login_params
        begin
          params.require(:session).permit(*LoginParams)
        rescue Exception
          params.permit(*LoginParams)
        end
      end
    end
  end # Api::V0
end
