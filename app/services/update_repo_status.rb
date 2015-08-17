class UpdateRepoStatus
  pattr_initialize :payload

  def run
    if repo
      repo.update(repo_attributes)
    end
  end

  private

  def repo
    @repo ||= Repo.active.find_by(github_id: payload.github_repo_id)
  end

  def repo_attributes
    {
      full_github_name: payload.full_repo_name,
      private: payload.private_repo?,
    }
  end
end
