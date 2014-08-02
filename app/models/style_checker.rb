# Filters files to reviewable subset.
# Builds style guide based on file extension.
# Delegates to style guide for line violations.
class StyleChecker
  def initialize(pull_request)
    @pull_request = pull_request
    @style_guides = {}
  end

  def violations
    @violations ||= files_to_check.flat_map do |file|
      style_guide(file.filename).violations_in_file(file)
    end
  end

  private

  attr_reader :pull_request, :style_guides

  def files_to_check
    pull_request.pull_request_files.select do |file|
      !file.removed? && style_guide(file.filename).enabled?
    end
  end

  def style_guide(filename)
    style_guide_class = style_guide_class(filename)
    style_guides[style_guide_class] ||= style_guide_class.new(config)
  end

  def style_guide_class(filename)
    case filename
    when /.*\.rb$/
      StyleGuide::Ruby
    when /.*\.coffee.?/
      StyleGuide::CoffeeScript
    else
      StyleGuide::Unsupported
    end
  end

  def config
    @config ||= RepoConfig.new(pull_request.head_commit)
  end
end
