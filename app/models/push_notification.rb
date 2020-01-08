class PushNotification
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user

  field :parent, type: BSON::ObjectId
  field :message, type: String

  def send_message
    Api::V0::PushNotificationsController.send_notification(self)
  end

  def json_info
    {
      :id      => id.to_s,
      :parent  => parent.to_s,
      :message => message,
    }
  end
end
