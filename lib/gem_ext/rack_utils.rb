module Rack
  module Utils
    HTTP_STATUS_CODES ||= {}
    HTTP_STATUS_CODES[420] = "Limit Excessed"
    HTTP_STATUS_CODES[529] = "Site Overloaded"
  end
end