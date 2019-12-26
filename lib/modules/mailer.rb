module Mailer
  @client = Postmark::ApiClient.new(ENV['POSTMARK_TOKEN'])
  SenderEmail = "00657121@email.ntou.edu.tw"
  ForgotMailBody = %{
    Dear %s, you have recently requested to reset your password.
    Please enter the following link to procesed.<br>
    https://%s?username=%s&token=%s
  }
  module_function
  
  # TODO
  def password_reset_url(domain)
    "#{domain}/account-recovery/reset"
  end

  def send(domain, target_email, username, token)
    # Send an email
    @client.deliver format_forgot_mail(domain, target_email, username, token)
  end
  
  def format_forgot_mail(domain, target_email, username, token)
    {
      from: SenderEmail,
      to: target_email,
      subject: 'Password reset request',
      html_body: sprintf(ForgotMailBody, username, 
        password_reset_url(domain), username, token),
      track_opens: true
    }
  end
end
