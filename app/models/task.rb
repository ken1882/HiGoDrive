class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user
  has_many :reviews

  field :dest, type: String
  field :depart_time, type: DateTime
  field :helmet, type: Boolean
  field :raincoat, type: Boolean

  validates :dest, presence: true
  validates :depart_time, presence: true

  def author; self.user; end
  def author_id; self.user_id; end
  
  def initialize(_params)
    _params[:helmet]   ||= false
    _params[:raincoat] ||= false
    _params[:depart_time] = Time.at _params[:depart_time].to_i
    super
  end

end
