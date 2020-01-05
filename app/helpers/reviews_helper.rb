module ReviewsHelper
  include ApplicationHelper
  private
  CommentLimit = 2000
  ReviewInitParam = [:id, :task_id, :score, :comment]
  
  # Use callbacks to share common setup or constraints between actions.

  def review_init_params
    filter_params ReviewInitParam
  end
end
