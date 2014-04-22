class EmailAddressJob
  extend Retryable

  @queue = :low

  def self.perform(user_id, github_token)
    user = User.find(user_id)
    github = GithubApi.new(github_token)
    email_address = github.email_address
    user.update_attribute(:email_address, email_address.downcase)
  rescue Resque::TermException
    Resque.enqueue(self, user_id, github_token)
  end
end
