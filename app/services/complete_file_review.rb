class CompleteFileReview
  def self.run(attributes)
    new(attributes).run
  end

  def initialize(attributes)
    @attributes = attributes
  end

  def run
    create_violations!

    BuildReport.run(
      pull_request: pull_request,
      build: build,
      token: build.user_token,
    )
  end

  private

  attr_reader :attributes

  def create_violations!
    attributes.fetch("violations").each do |violation|
      line = commit_file.line_at(violation.fetch("line"))
      file_review.build_violation(line, violation.fetch("message"))
    end

    file_review.complete
    file_review.save!
    file_review.build.increment!(
      :violations_count,
      file_review.violations.map(&:messages_count).sum,
    )
  end

  def pull_request
    PullRequest.new(payload, Hound::GITHUB_TOKEN)
  end

  def payload
    Payload.new(build.payload)
  end

  def build
    @build ||= Build.find_by!(
      pull_request_number: attributes.fetch("pull_request_number"),
      commit_sha: attributes.fetch("commit_sha"),
    )
  end

  def file_review
    @file_review ||= build.file_reviews.find_by!(file_review_properties)
  end

  def file_review_properties
    if attributes.has_key?("linter_name")
      legacy_file_review_search_properties.merge(
        linter_name: attributes.fetch("linter_name"),
      )
    else
      legacy_file_review_search_properties
    end
  end

  def legacy_file_review_search_properties
    { filename: attributes.fetch("filename") }
  end

  def commit_file
    @commit_sha ||= CommitFile.new(
      patch: attributes.fetch("patch"),
      filename: nil,
      commit: nil,
    )
  end
end
