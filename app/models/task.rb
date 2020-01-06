class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  has_many :reviews
  has_many :reports

  field :dest, type: String
  field :depart_time, type: DateTime
  field :status, type: Integer
  field :equipments, type: Integer
  field :driver_id, type: BSON::ObjectId
  field :reject_reasons, type: Array

  validates :dest, presence: true
  validates :depart_time, presence: true

  ProgressStatus = {
    :new      => 0,
    :accepted => 1,
    :engaging => 2,
    :finished => 3,
    :canceled => 4,
  }

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
    _params[:equipments] ||= 0
    _params[:status]       = 0
    _params[:depart_time]  = Time.at(_params[:depart_time].to_i)
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
      author_name: author.username,
      dest: dest,
      depart_time: depart_time.to_i,
      driver_id: driver_id.to_s,
      driver_name: driver ? driver.username : nil,
      equipments: equipments,
      status: status
    }
  end

  def accept(_did)
    @@mutex.synchronize{$task_queue.delete(self.id.to_i)}
    self.update({
      status: ProgressStatus[:accepted],
      driver_id: _did
    })
    driver.engage_task(self.id)
  end

  def engage
    update_attribute :status, ProgressStatus[:engaging]
  end

  def finish
    update_attribute :status, ProgressStatus[:finished]
    driver.resolve_task(self.id)
  end

  def cancel
    update_attribute :status, ProgressStatus[:canceled]
    driver.resolve_task(self.id)
  end

  def reject(msg)
    self.add_to_set(reject_reasons: msg)
  end

  def accepted?
    (status || 0) != ProgressStatus[:new]
  end

  def engaging?
    status == ProgressStatus[:engaging]
  end

  def closed?
    (status || 0) >= ProgressStatus[:finished]
  end

  def driver
    return @driver = nil unless driver_id
    return @driver if @driver
    return @driver = User.find(driver_id)
  end
end
