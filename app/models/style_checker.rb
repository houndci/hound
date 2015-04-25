# Filters files to reviewable subset.
# Builds style guide based on file extension.
# Delegates to style guide for line violations.
class StyleChecker
  def initialize(pull_request)
    @pull_request = pull_request
    @style_guides = {}
  end

  def violations
    @violations ||= Violations.new.push(*violations_in_checked_files).to_a
  end

  private

  attr_reader :pull_request, :style_guides

  def violations_in_checked_files
    files_to_check.flat_map do |file|
      style_guide(file.filename).violations_in_file(file)
    end
  end

  def files_to_check
    pull_request.pull_request_files.select do |file|
      file_style_guide = style_guide(file.filename)
      file_style_guide.enabled? && file_style_guide.file_included?(file)
    end
  end

  def style_guide(filename)
    style_guide_class = style_guide_class(filename)
    style_guides[style_guide_class] ||= style_guide_class.new(
      config,
      pull_request.repository_owner_name
    )
  end

  def style_guide_class(filename)
    case filename
    when /.+\.rb\z/
      StyleGuide::Ruby
    when /.+\.coffee(\.js)?(\.erb)?\z/
      StyleGuide::CoffeeScript
    when /.+\.js\z/
      StyleGuide::JavaScript
    when /.+\.scss\z/
      StyleGuide::Scss
    else
      StyleGuide::Unsupported
    end
  end

  def config
    @config ||= RepoConfig.new(pull_request.head_commit)
  end
end
