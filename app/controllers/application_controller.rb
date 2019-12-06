class ApplicationController < ActionController::Base
  protect_from_forgery with: :http_code
  include SessionHelper

  def return_ok(*args); return_httpcode(200, *args); end
  def bad_request(*args); return_httpcode(400, *args); end
  def not_acceptable(*args); return_httpcode(406, *args); end
  def forbidden(*args); return_httpcode(403, *args); end
  def not_found(*args); return_httpcode(404, *args); end
  def unauthorized(*args); return_httpcode(401, *args); end
  def unprocessable_entity(*args); return_httpcode(422, *args); end
  def unsupported_media_type(*args); return_httpcode(415, *args); end
  def internel_error(*args); return_httpcode(500, *args); end

  private
  def return_httpcode(code, *messages, **kwargs)
    sep   = kwargs[:sep] 
    sep ||= "\n"
    respond_to do |format|
      msg = messages.size == 0 ? Rack::Utils::HTTP_STATUS_CODES[code] : messages.join(sep)
      format.html {
        if File.exist?("#{Rails.root}/public/#{code}.html")
          redirect_to "/#{code}.html"
        else
          render html: Rack::Utils::HTTP_STATUS_CODES[code]
        end
      }
      format.json {render json: {message: msg}, status: code}
    end
  end

end
