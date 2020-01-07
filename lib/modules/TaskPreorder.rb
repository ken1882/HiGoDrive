class TaskPreorder
  attr_reader :uid, :time
  def initialize(uid, _time)
    @uid  = uid
    @time = _time.to_i
  end

  def times_up?
    Time.now.to_i >= @time
  end

  def execute
    
  end
end