module Mailer
  @client = Postmark::ApiClient.new(ENV['POSTMARK_TOKEN'])
  SenderEmail = "00657121@email.ntou.edu.tw"

  module_function
  
  # TODO
  def password_reset_url
    "/"
  end

  def send(target_email, username, token)
    # Send an email
    @client.deliver(
      from: SenderEmail,
      to: target_email,
      subject: 'Password reset request',
      html_body: "#{password_reset_url}?username=#{username}&token=#{token}",
      track_opens: true
    )
	end
end