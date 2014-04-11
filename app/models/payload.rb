require 'json'

class Payload
  def initialize(payload_data)
    if payload_data.is_a? String
      @payload_data = JSON.parse(payload_data)
    else
      @payload_data = payload_data
    end
  end

  def head_sha
    @payload_data['pull_request']['head']['sha']
  end

  def github_repo_id
    @payload_data['repository']['id']
  end

  def full_repo_name
    @payload_data['repository']['full_name']
  end

  def number
    @payload_data['number']
  end

  def action
    @payload_data['action']
  end

  def changed_files
    @payload_data['pull_request']['changed_files']
  end
end
