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
        WebpushJob.perform_later notification.json_info,
          endpoint: user.endpoint,
          p256dh: user.p256dh,
          auth: user.auth
      end

      def self.send_task_accepted(_task)
        msg = sprintf(MessageTaskAccepted, _task.id.to_s[0...4], _task.driver.name)
        self.create_notification(_task.user, msg)
      end

      def self.send_preorder_accepted(_task)
        msg = sprintf(MessagePreorderAccepted, _task.driver.name)
        self.create_notification(_task.user, msg)
      end

      def self.send_license_accepted(user)
        msg = "Your license has been approved"
        self.create_notification(user, msg) rescue nil
      end

      def self.send_license_rejected(user)
        msg = "Your license has been rejected"
        self.create_notification(user, msg) rescue nil
      end

      def self.send_license_uploaded(user)
        msg = "Your license will be reviewed soon, please wait"
        self.create_notification(user, msg) rescue nil
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

        WebpushJob.perform_later TestNotification,
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