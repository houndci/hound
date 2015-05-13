# Cannot extend ActiveJob, must match class used in service
class ReviewJob
  @queue = :high

  def self.perform(attributes)
    # repo_name
    # filename
    # commit_sha
    # patch
    # violations
    #   line
    #   message

    filename = attributes.fetch("filename")
    file = CommitFile.new(
      file: OpenStruct.new(
        filename: filename,
        patch: attributes.fetch("patch")
      ),
      commit: nil
    )

    repo = Repo.find_by(full_github_name: attributes.fetch("repo_name"))
    # are there going to be multiple builds for the same sha?
    build = repo.builds.find_by(commit_sha: attributes.fetch("commit_sha"))

    attributes.fetch("violations").each do |violation|
      line = file.line_at(violation["line"])

      build.violations << Violation.new(
        filename: filename,
        patch_position: line.patch_position,
        line: line,
        line_number: line.number,
        messages: [violation["message"]]
      )
    end

    build.violations.where(pending: true, filename: filename).destroy!

    # Update GitHub status when no pending violations exist
    # Could create commit object and get GitHub API object from it
  end
end
