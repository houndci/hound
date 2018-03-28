class StyleChecker
  pattr_initialize :pull_request, :build

  def review_files
    pull_request.commit_files.each { |commit_file| review_file(commit_file) }
  end

  private

  def review_file(commit_file)
    find_able_linters(commit_file.filename).
      select(&:enabled?).
      select { |linter| linter.file_included?(commit_file) }.
      each { |linter| linter.file_review(commit_file) }
  end

  def find_able_linters(filename)
    HoundConfig::LINTERS.keys.
      select { |linter_class| linter_class.can_lint?(filename) }.
      map { |linter_class| build_linter(linter_class) }
  end

  def build_linter(linter_class)
    linter_class.new(hound_config: hound_config, build: build)
  end

  def hound_config
    @_hound_config ||= HoundConfig.new(
      commit: pull_request.head_commit,
      owner: build.repo.owner,
    )
  end
end
