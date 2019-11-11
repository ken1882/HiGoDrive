module ApplicationHelper
  def flash_messages
    _re = flash.inject(''){ |str, info|
      type, msg = *info
      str + "<div class=\"alert alert-#{type}\">#{msg}</div>"
    }.html_safe
  end
end
