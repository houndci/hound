require 'json'

class Commit
  attr_reader :data

  def initialize(payload)
    @data = JSON.parse(payload)
  end

  def full_repo_name
    "#{repo_owner}/#{repo_name}"
  end

  def id
    data["commits"][0]["id"]
  end

  private

  def repo_name
    data["repository"]["name"]
  end

  def repo_owner
    data["repository"]["owner"]["name"]
  end
end
