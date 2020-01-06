module Mailer
  require 'gmail'

  @gmail = Gmail.new(ENV['EMAIL_NAME'], ENV['EMAIL_PASSWORD'])

  module_function
  
  # TODO
  def password_reset_url
    "/"
  end

  def send(target_email, username, token)
    # Send an email
    email = @gmail.generate_message do
      to target_email
      subject 'Password reset request'
      body "#{password_reset_url}?username=#{username}&token=#{token}"
    end
    email.deliver!

    @gmail.deliver(email)
  end
end