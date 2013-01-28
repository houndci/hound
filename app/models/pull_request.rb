class PullRequest
  attr_reader :data

  def initialize(data)
    @data = JSON.parse(data)
  end

  def repo_name
    head['repo']['full_name']
  end

  def sha
    head['sha']
  end

  def user_login
    head['user']['login']
  end

  private

  def head
    data['head']
  end
end
