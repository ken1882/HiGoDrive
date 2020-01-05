module ReportsHelper
  include ApplicationHelper
  private
  CommentLimit = [10, 2000]
  ReportInitParams = [:id, :task_id, :comment]

  # Never trust parameters from the scary internet, only allow the white list through.
  def report_init_params
    filter_params ReportInitParams
  end
end
