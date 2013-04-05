require 'json'

class Commit
  def initialize(payload)
    @data = JSON.parse(payload)
  end

  def full_repo_name
    "#{repo_owner}/#{repo_name}"
  end

  def id
    @data['commits'][0]['id']
  end

  def previous_commit_id
    @data['before']
  end

  def pusher
    @data['pusher']['name']
  end

  private

  def repo_name
    @data['repository']['name']
  end

  def repo_owner
    @data['repository']['owner']['name']
  end
end
