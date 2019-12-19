module Util
  module_function
  def email_deliverable?(email)
    JSON.load(open("https://api.trumail.io/v2/lookups/json?email=#{email}"))['deliverable']
  end

  def format_phone_number(number)
    return nil if number.nil?
    begin
      num = number.split('-')
      num[0] = sprintf("+%d", num[0].tr('+','').to_i)
      num[1] = sprintf("%03d", num[1].to_i)
      num.join('-')
    rescue Exception
      return nil
    end
  end
end
