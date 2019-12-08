module Mailer
  @client = Postmark::ApiClient.new('70d9121b-0589-4df6-9ae6-c759114d3997')
	module_function
  def send(username, token)
    # Send an email:
    client.deliver(
      from: '00657121@email.ntou.edu.tw',
      to: 'ludanwang@universetech.cc',
      subject: 'Hello from Postmark',
      html_body: '<strong>Hello</strong> dear Postmark user.',
      track_opens: true
     )
	end
end