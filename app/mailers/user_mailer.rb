class UserMailer < ApplicationMailer
	def hello
    mail(
      :subject => 'Hello from Postmark',
      :to  => 'ludanwang@universetech.cc',
      :from => '00657121@email.ntou.edu.tw',
      :html_body => '<strong>Hello</strong> dear Postmark user.',
      :track_opens => 'true')
  end
end
