require 'json'

class Payload
  pattr_initialize :unparsed_data

  def data
    @data ||= parse_data
  end

  def head_sha
    pull_request.fetch("head", {})["sha"]
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
    pull_request["changed_files"] || 0
  end

  def ping?
    data['zen']
  end

  private

  def parse_data
    if unparsed_data.is_a? String
      JSON.parse(unparsed_data)
    else
      unparsed_data
    end
  end

  def pull_request
    data.fetch("pull_request", {})
  end
end
