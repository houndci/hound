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
    filename = attributes.fetch("filename")
    file = OpenStruct.new(
      filename: filename,
      patch: attributes.fetch("patch")
    )
    commit = Commit.new(repo.full_github_name, build.commit_sha, nil)
    commit_file = CommitFile.new(file, commit)
    violations = Violations.new

    attributes.fetch("violations").each do |violation|
      line = commit_file.line_at(violation.fetch("line"))

      violations.push(
        # why pass all line info separately?
        Violation.new(
          filename: filename,
          line: line,
          line_number: line.number,
          messages: [violation.fetch("message")],
          patch_position: line.patch_position
        )
      )
    end

    build.violations = violations.to_a
  end
end
