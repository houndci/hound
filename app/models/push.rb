class Push < Event
  def commits
    @commits ||= payload.commits.map do |commit_data|
      Commit.new(full_repo_name, commit_data["id"], api)
    end
  end

  private

  def head_commit
    commits.first
  end
end
