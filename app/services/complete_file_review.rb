class CompleteFileReview
  static_facade :call

  def initialize(attributes)
    @attributes = attributes
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
    file_review.error = attributes["error"]
    file_review.complete
    file_review.save!
    increment_build_violations_count
  end

  def build_file_review_violations
    attributes.fetch("violations").each do |violation|
      line = commit_file.line_at(violation.fetch("line"))
      file_review.build_violation(line, violation.fetch("message"))
    end
  end

  def increment_build_violations_count
    count = file_review.violations.map(&:messages_count).sum
    file_review.build.increment!(:violations_count, count)
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
    @_commit_file ||= CommitFile.new(
      patch: attributes.fetch("patch"),
      filename: nil,
      commit: nil,
    )
  end
end
