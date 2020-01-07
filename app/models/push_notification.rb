class PushNotification
  include Mongoid::Document
  include Mongoid::Timestamps

  field :parent, type: BSON::ObjectId
  field :message, type: String
end
