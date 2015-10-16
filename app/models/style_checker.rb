# Filters files to reviewable subset.
# Builds style guide based on file extension.
# Delegates to style guide for line violations.
class StyleChecker
  pattr_initialize :pull_request, :build

  def review_files
    pull_request.commit_files.each do |commit_file|
      collection = build_linter_collection(commit_file.filename)

      collection.file_review(commit_file)
    end
  end

  private

  def build_linter_collection(filename)
    Linter::Collection.for(
      filename: filename,
      hound_config: hound_config,
      build: build,
      repository_owner_name: pull_request.repository_owner_name,
    )
  end

  def hound_config
    @hound_config ||= HoundConfig.new(pull_request.head_commit)
  end
end
