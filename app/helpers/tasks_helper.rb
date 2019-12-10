module TasksHelper
  include ApplicationHelper
  private
  TaskInitParams = [:dest]
  

  def task_init_params
    filter_params TaskInitParams
  end
end
