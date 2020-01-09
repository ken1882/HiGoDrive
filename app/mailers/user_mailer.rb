class UserMailer < ApplicationMailer
  def reset_email(domain, user, token)
    @domain = domain
    @user   = user
    @token  = token
    mail(to: @user.email, subject: 'Password Reset Request')
  end
end
