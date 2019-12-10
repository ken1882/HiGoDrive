class Task
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :user
  has_many :reviews

  field :dest, type: String
  field :depart_time, type: DateTime
  field :helmet, type: Boolean
  field :raincoat, type: Boolean
  field :status, type: Integer

  validates :dest, presence: true
  validates :depart_time, presence: true

  @@mutex = Mutex.new
  @@next_id = (self.all.last.id.to_i rescue 0) + 1

  def self.setup
    $task_queue = []
    self.all.each do |task|
      next if task.accepted?
      $task_queue << task.id.to_i
    end
  end
  def self.mutex; @@mutex; end
  
  def initialize(_params)
    _params[:helmet]    ||= false
    _params[:raincoat]  ||= false
    _params[:status]      = 0
    _params[:depart_time] = Time.at(_params[:depart_time].to_i)
    @@mutex.synchronize{
      $task_queue << @@next_id
      _params[:id] = @@next_id
      @@next_id += 1
    }
    super
  end

  def author; self.user; end
  def author_id; self.user_id; end  

  def public_json_info
    {
      author_id: author_id.to_s,
      dest: dest,
      depart_time: depart_time.to_i,
      helmet: helmet,
      raincoat: raincoat,
      status: status
    }
  end

  def finish
    @@mutex.synchronize{$task_queue.delete(self.id.to_i)}
    update_attribute :status, 1
  end

  def accepted?; (self.attributes[:status] || 0) != 0; end
end
