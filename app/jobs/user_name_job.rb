require "nokogiri"
require "open-uri"

class UserNameJob
  extend Retryable

  @queue = :low

  def self.perform(user_id)
    user = User.find(user_id)
    page = Nokogiri::HTML(open("https://www.github.com/#{user.github_username}"))
    name = page.css(".vcard-fullname").text
    user.update_attributes!(name: name)
  rescue Resque::TermException
    Resque.enqueue(self, user_id)
  end
end
