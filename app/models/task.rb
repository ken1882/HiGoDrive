class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user
  has_many :reviews

  field :dest, type: String

  validates :dest, presence: true


  def author; self.user; end
  def author_id; self.user_id; end
  
end
