module TasksHelper
  include ApplicationHelper
  private
  TaskInitParams = [:dest, :depart_time, :equipments]

  def task_init_params
    filter_params TaskInitParams
  end
end
