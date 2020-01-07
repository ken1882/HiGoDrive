module Api
  module V0
    class PushNotificationsController < ApplicationController
      include PushNotificationsHelper
      before_action :verify_login
      before_action :set_user

      def self.create_notification(user, message='Yay! A Notification!')
        user = User.wide_query(user) unless user.is_a? User
        user.push_notifications.create({
          :parent  => user.id,
          :message => message
        })
      end

      def self.send_notification(notification)
        user = User.find(notification.parent)
        WebpushJob.perform_later notification.message,
          endpoint: user.endpoint,
          p256dh: user.p256dh,
          auth: user.auth
      end

      # POST /push_notifications
      def create
        @user.update(
          {
            endpoint: subscription_params[:endpoint],
            p256dh: subscription_params.dig(:keys, :p256dh),
            auth: subscription_params.dig(:keys, :auth)
          }
        )
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