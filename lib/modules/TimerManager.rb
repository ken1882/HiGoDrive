module TimerManager
  SleepDuration = 5   # sec
  
  @@mutex = Mutex.new

  mattr_reader :thread
  module_function
  def initialize
    @flag_busy = false
    @preorder_queue = []
    @thread    = Thread.new{start}
  end

  def start
    loop do
      sleep(SleepDuration)
      update_preorders
    end
  end

  def add_preorder(task_id, _time)
    @@mutex.synchronize {
      @preorder_queue << TaskPreorder.new(task_id, _time)
    }
  end

  def update_preorders
    processed_idx = []
    @preorder_queue.each_with_index do |order, i|
      next unless order.times_up?
      processed_idx << i
      order.execute
    end
    delete_preorder(processed_idx)
  end

  def delete_preorder(*idx)
    @@mutex.synchronize{
      idx.flatten.reverse_each{|i| @preorder_queue.delete_at(i)}
    }
  end

  def busy?; @flag_busy; end
end