module ReviewsHelper
  include ApplicationHelper
  private
  CommentLimit = 2000
  ReviewInitParam = [:id, :score, :comment]

  # Use callbacks to share common setup or constraints between actions.

  def review_init_param
    filter_params ReviewInitParam
  end
end
