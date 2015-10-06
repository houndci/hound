# vim:fileencoding=utf-8

class User < ActiveRecord::Base
  after_create :schedule_send_email

  private

  def schedule_send_email
    name = "send_email_#{id}"
    config = {}
    config[:class] = 'SendEmailJob'
    config[:args] = id
    config[:every] = '1d'
    Resque.set_schedule(name, config)
  end
end
