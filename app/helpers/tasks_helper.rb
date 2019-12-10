module TasksHelper
  include ApplicationHelper
  private
  TaskInitParams = [:dest, :depart_time, :helmet, :raincoat]

  def task_init_params
    filter_params TaskInitParams
  end
end
