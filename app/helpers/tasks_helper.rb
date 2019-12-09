module TasksHelper
  include ApplicationHelper
  private
  TaskInitParams = [:type, :title, :end_day, :end_time, :pos, 
    :pos_info, :event_start, :event_end, :avatar_url, :dest]
  

  def task_init_params
    filter_params TaskInitParams
  end
end
