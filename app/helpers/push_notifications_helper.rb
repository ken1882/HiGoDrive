module PushNotificationsHelper
  include ApplicationHelper

  TestNotification = {
    :id      => 0,
    :parent  => 0,
    :message => "Yay, we sent you a push notification!",
  }

  MessageTaskAccepted = "Your request#%s has been accepted by %s"
  MessagePreorderAccepted = "Your preorder to %s has been accepted"

  def push_params
    params.permit(:message, { subscription: [:endpoint, keys: [:auth, :p256dh]]})
  end

  def fetch_message
    push_params.fetch(:message, "Yay, you sent a push notification!")
  end
  
  def fetch_subscription_params
    @subscription_params ||= push_params.fetch(:subscription) { extract_session_subscription }
  end

  def extract_session_subscription
    subscription = session.fetch(:subscription){
      raise PushNotificationError, "Cannot create notification: no :subscription in params or session"
    }
    JSON.parse(subscription).with_indifferent_access
  end
end
