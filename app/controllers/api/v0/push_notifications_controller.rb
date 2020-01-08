module Api
  module V0
    class PushNotificationsController < ApplicationController
      include PushNotificationsHelper
      before_action :verify_login
      before_action :set_user

      def self.create_notification(user, message='Yay! A Notification!')
        user = User.wide_query(user) unless user.is_a? User
        msg  = user.push_notifications.create({
          :parent  => user.id,
          :message => message
        })
      end

      def self.send_notification(notification)
        user = User.find(notification.parent)
        return if user.nil?
        WebpushJob.perform_later notification.message,
          endpoint: user.endpoint,
          p256dh: user.p256dh,
          auth: user.auth
      end

      # GET /push_notifications
      def index
        render json: @user.push_notifications.collect{|n| n.json_info}, status: :ok
      end

      # POST /push_notifications
      # Register push notifications
      def create
        Rails.logger.info "Sending push notification from #{push_params.inspect}"
        subscription_params = fetch_subscription_params
        @user.update(
          {
            endpoint: subscription_params[:endpoint],
            p256dh: subscription_params.dig(:keys, :p256dh),
            auth: subscription_params.dig(:keys, :auth)
          }
        )
        return_ok
      end      

      def test_send
        Rails.logger.info "Sending push notification from #{push_params.inspect}"
        subscription_params = fetch_subscription_params

        WebpushJob.perform_later fetch_message,
          endpoint: subscription_params[:endpoint],
          p256dh: subscription_params.dig(:keys, :p256dh),
          auth: subscription_params.dig(:keys, :auth)

        head :ok
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