module Util
  module_function
  def email_deliverable?(email)
    JSON.load(open("https://api.trumail.io/v2/lookups/json?email=#{email}"))['deliverable']
  end
end