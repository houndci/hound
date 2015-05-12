class ReviewJob < ApplicationJob
  queue_as :review

  def perform
    # repo_name
    # filename
    # commit_sha
    # violations
    #   line
    #   message

    file = CommitFile.new(
      file: OpenStruct.new(
        filename: params.fetch(:filename),
        patch: params.fetch(:patch)
      ),
      commit: nil
    )

    repo = Repo.find_by(full_github_name: params.fetch(:repo_name))
    # are there going to be multiple builds for the same sha?
    build = repo.builds.find_by(commit_sha: params.fetch(:commit_sha))

    params.fetch(:violations).each do |violation|
      line = file.line_at(violation[:line])

      build.violations << Violation.new(
        filename: file.filename,
        patch_position: line.patch_position,
        line: line,
        line_number: line.number,
        messages: [violation[:message]]
      )
    end

    build.violations.pending.find_by(filename: filename).destroy!

    # Update GitHub status when no pending violations exist
    # Could create commit object and get GitHub API object from it
  end
end
