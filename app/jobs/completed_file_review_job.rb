class CompletedFileReviewJob
  @queue = :high

  def self.perform(attributes)
    # filename
    # commit_sha
    # pull_request_number
    # patch
    # violations
    #   [{ line: 123, message: "WAT" }]

    build = Build.find_by!(
      pull_request_number: attributes.fetch("pull_request_number"),
      commit_sha: attributes.fetch("commit_sha")
    )
    file_review = build.file_reviews.find_by!(
      filename: attributes.fetch("filename")
    )
    commit_file = CommitFile.new(
      filename: file_review.filename,
      content: "",
      patch: attributes.fetch("patch"),
      pull_request_number: attributes.fetch("pull_request_number"),
      sha: build.commit_sha
    )

    attributes.fetch("violations").each do |violation|
      line = commit_file.line_at(violation.fetch("line"))
      file_review.build_violation(line, violation.fetch("message"))
    end

    file_review.complete
    file_review.save!

    payload = Payload.new(build.payload)
    pull_request = PullRequest.new(payload, Hound::GITHUB_TOKEN)

    BuildReport.run(
      pull_request: pull_request,
      build: build,
      token: build.user_token,
    )
  rescue ActiveRecord::RecordNotFound
    Resque.enqueue_in(30, self, attributes)
  rescue Resque::TermException
    Resque.enqueue(self, attributes)
  end
end
