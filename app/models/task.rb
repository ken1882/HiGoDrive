class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user
  has_many :reviews

  field :pos, type: String
  field :pos_info, type: String
  field :dest, type: String

  validates :pos, presence: true
  validates :dest, presence: true
  
end
