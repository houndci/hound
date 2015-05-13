class Payload
  pattr_initialize :unparsed_data

  def data
    @data ||= parse_data
  end

  def head_sha
    pull_request.fetch("head", {})["sha"]
  end

  def github_repo_id
    repository["id"]
  end

  def full_repo_name
    repository["full_name"]
  end

  def pull_request_number
    data['number']
  end

  def action
    data['action']
  end

  def changed_files
    pull_request["changed_files"] || 0
  end

  def ping?
    data["zen"]
  end

  def pull_request?
    pull_request.present?
  end

  def repository_owner_id
    repository["owner"]["id"]
  end

  def repository_owner_name
    repository["owner"]["login"]
  end

  def repository_owner_is_organization?
    repository["owner"]["type"] == GithubApi::ORGANIZATION_TYPE
  end

  def build_data
    {
      "number" => pull_request_number,
      "action" => action,
      "pull_request" => {
        "changed_files" => changed_files,
        "head" => {
          "sha" => head_sha,
        }
      },
      "repository" => {
        "id" => github_repo_id,
        "full_name" => full_repo_name,
        "owner" => {
          "id" => repository_owner_id,
          "login" => repository_owner_name,
          "type" => repository["owner"]["type"],
        }
      }
    }
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

  def repository
    @repository ||= data["repository"]
  end
end
