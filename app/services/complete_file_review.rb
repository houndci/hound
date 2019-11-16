class CompleteFileReview
  static_facade :call

  def initialize(attributes)
    @attributes = attributes.deep_symbolize_keys
  end

  def call
    complete_file_review

    if build.completed?
      CompleteBuild.call(build)
    end
  end

  private

  attr_reader :attributes

  def complete_file_review
    build_file_review_violations
    file_review.error = attributes[:error]
    file_review.complete
    file_review.save!
  end

  def build_file_review_violations
    attributes.fetch(:violations).each do |violation|
      line = commit_file.line_at(violation.fetch(:line))

      file_review.build_violation(
        line,
        violation.fetch(:message),
        violation.fetch(:source)
      )
    end
  end

  def build
    @build ||= Build.find_by!(
      pull_request_number: attributes.fetch(:pull_request_number),
      commit_sha: attributes.fetch(:commit_sha),
    )
  end

  def file_review
    @file_review ||= build.file_reviews.find_by!(file_review_properties)
  end

  def file_review_properties
    attributes.slice(:filename, :linter_name)
  end

  def commit_file
    @_commit_file ||= CommitFile.new(
      patch: attributes.fetch(:patch),
      filename: nil,
      commit: nil,
    )
  end
end
