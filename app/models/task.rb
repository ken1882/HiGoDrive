class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user

  field :type, type: Integer
  field :title, type: String
  field :end_date, type: String
  field :end_day, type: String
  field :pos, type: String
  field :pos_info, type: String
  field :event_start, type: DateTime
  field :event_end, type: DateTime
  field :avatar_url, type: String
  field :dest, type: String

  validates :type, presence: true
  validates :pos, presence: true
  validates :dest, presence: true
  validates :title, presence: true, length: {in: 3..255}
end
