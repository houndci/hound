require 'json'

class Payload
  attr_reader :data

  def initialize(data)
    if data.is_a? String
      @data = JSON.parse(data)
    else
      @data = data
    end
  end

  def head_sha
    data['pull_request']['head']['sha']
  end

  def github_repo_id
    data['repository']['id']
  end

  def full_repo_name
    data['repository']['full_name']
  end

  def number
    data['number']
  end

  def action
    data['action']
  end

  def changed_files
    data['pull_request']['changed_files']
  end

  def ping?
    data['zen']
  end
end
