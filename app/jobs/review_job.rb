class ReviewJob < ActiveJob::Base
  extend Retryable

  def perform(params)
    # repo_name
    # filename
    # commit
    # content
    # violations
    #   line
    #   message

    filename = params.fetch(:filename)
    patch = Patch.new(params.fetch(:patch))

    repo = Repo.find_by(full_github_name: params.fetch(:repo_name))
    # are there going to be multiple builds for the same sha?
    build = repo.builds.find_by(commit_sha: params.fetch(:commit))

    file = CommitFile.new(
      filename: filename,
      patch: patch
    )

    violations.each do |violation|
      line = file.line_at(violation[:line])

      build.violations << Violation.new(
        filename: filename,
        patch_position: line.patch_position,
        line: line,
        line_number: line.number,
        messages: [violation[:message]]
      )
    end

    build.violations.pending.find_by(filename: filename).destroy!

    # Update GitHub status when no pending violations exist
  end
end
