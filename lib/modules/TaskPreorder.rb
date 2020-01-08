class TaskPreorder
  attr_reader :task_id, :time
  def initialize(task_id, _time)
    @uid  = task_id
    @time = _time.to_i
  end

  def times_up?
    Time.now.to_i >= @time
  end

  def execute
    # TODO
  end
end