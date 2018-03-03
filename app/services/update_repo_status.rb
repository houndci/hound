# frozen_string_literal: true

class UpdateRepoStatus
  static_facade :call
  pattr_initialize :payload

  def call
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
      name: payload.full_repo_name,
      private: payload.private_repo?,
    }
  end
end
