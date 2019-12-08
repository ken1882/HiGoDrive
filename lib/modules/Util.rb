module Util
  module_function
  def email_deliverable?(email)
    JSON.load(open("https://api.trumail.io/v2/lookups/json?email=#{email}"))['deliverable']
  end

  def load_smtp_settings
    ENV['SMTP_SETTINGS'].split(',').collect{ |s|
      s.split(':').tap{|a| a[0] = a[0].to_sym}
    }.to_h.tap{|c| c[:enable_starttls_auto] = c[:enable_starttls_auto] == '1' ? true : false}
  end
end