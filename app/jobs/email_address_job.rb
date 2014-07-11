class EmailAddressJob
  extend Retryable

  @queue = :high

  def self.perform(user_id, github_token)
    user = User.find(user_id)
    github = GithubApi.new(github_token)
    email_address = github.email_address
    if user.reload.email_address.blank?
      user.update(email_address: email_address.downcase)
    end
  rescue Resque::TermException
    Resque.enqueue(self, user_id, github_token)
  end
end
