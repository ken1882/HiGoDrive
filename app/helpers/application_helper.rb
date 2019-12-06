module ApplicationHelper
  def flash_messages
    _re = flash.inject(''){ |str, info|
      type, msg = *info
      str + "<div class=\"alert alert-#{type}\">#{msg}</div>"
    }.html_safe
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def filter_params(param_set)
    begin
      params.require(:user).permit(*param_set)
    rescue Exception
      params.permit(*param_set)
    end
  end
  
end
