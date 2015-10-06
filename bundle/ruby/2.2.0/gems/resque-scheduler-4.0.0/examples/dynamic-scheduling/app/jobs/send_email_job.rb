# vim:fileencoding=utf-8

class SendEmailJob
  @queue = :send_emails

  def self.perform(_user_id)
    # ... do whatever you have to do to send an email to the user
  end
end
