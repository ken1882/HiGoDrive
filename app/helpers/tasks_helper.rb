module TasksHelper
  include ApplicationHelper
  private
  TaskInitParams   = [:dest, :depart_time, :equipments]
  TaskRejectParams = [:id, :reason]
  TaskPreorderParams = [:dest, :depart_time, :equipments, :driver_id]

  def task_init_params
    filter_params TaskInitParams
  end

  def task_reject_params
    filter_params TaskRejectParams
  end
end
