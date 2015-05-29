class CompletedReviewJob
  @queue = :high

  # repo_name
  # filename
  # commit_sha
  # patch
  # violations
  #  - line
  #  - message

  def self.perform(attributes)
    repo = Repo.find_by(full_github_name: attributes.fetch("repo_name"))
    build = repo.builds.find_by(commit_sha: attributes.fetch("commit_sha"))
    file_review = build.file_reviews.find_by(filename: attributes.fetch("filename"))
    file = OpenStruct.new(
      filename: file_review.filename,
      patch: attributes.fetch("patch")
    )
    commit = Commit.new(repo.full_github_name, build.commit_sha, nil)
    commit_file = CommitFile.new(file, commit)

    attributes.fetch("violations").each do |violation|
      line = commit_file.line_at(violation.fetch("line"))
      file_review.build_violation(line, line.number, violation.fetch("message"))
    end

    file_review.complete

    # comment on violations
    # not keeping track of "max comments" made
    # always using Hound token
    # TEST ME, PLEASE
    # don't have payload?
    pull_request = PullRequest.new(build.payload, ENV["HOUND_GITHUB_TOKEN"])
    commenter = Commenter.new(pull_request)
    commenter.comment_on_violations(file_review.violations)

    if build.complete?
      github.create_success_status(
        repo.full_github_name,
        build.commit_sha,
        I18n.t(:success_status, count: build.violations.count)
      )
    end
  end
end
