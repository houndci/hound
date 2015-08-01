class CompletedFileReviewJob < ApplicationJob
  queue_as :high

  # attributes is a hash with the following required keys:
  # - filename
  # - commit_sha
  # - pull_request_number
  # - patch
  # - violations (an array)
  #   Example: [{ line: 123, message: "WAT" }]
  def perform(attributes)
    build = Build.find_by!(
      pull_request_number: attributes.fetch("pull_request_number"),
      commit_sha: attributes.fetch("commit_sha")
    )
    file_review = build.file_reviews.find_by(
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
  end
end
