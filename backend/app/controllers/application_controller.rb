class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  def bad_request; return_cat 400; end
  def not_acceptable; return_cat 406; end
  def forbidden; return_cat 403; end
  def not_found; return_cat 404; end

  def return_cat(code)
    if request.xhr?
      render json: {message: Rack::Utils::HTTP_STATUS_CODES[code]}, status: code
    else
      redirect_to "https://http.cat/#{code}"
    end
  end
end
