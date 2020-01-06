module Api
  module V0
    class PushNotificationsController < ApplicationController
      include PushNotificationsHelper
      before_action :verify_login
      before_action :set_user

      def self.send_notification(target_id, message)
        @target = User.find(target_id)
        return 404 if @target_id.nil?
        
      end

      # /push_register
      def create
        Rails.logger.info "Sending push notification from #{push_params.inspect}"
        subscription_params = fetch_subscription_params
    
        WebpushJob.perform_later fetch_message,
          endpoint: subscription_params[:endpoint],
          p256dh: subscription_params.dig(:keys, :p256dh),
          auth: subscription_params.dig(:keys, :auth)
    
        return_ok
      end      

      private
      def verify_login
        return unauthorized unless logged_in?
        return true
      end

      def set_user
        @user = current_user
      end
    end    
  end
end