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
    pull_request.pull_request_files.reject(&:removed?)
  end

  def style_guide(filename)
    style_guide_class = style_guide_class(filename)
    style_guides[style_guide_class] ||= style_guide_class.new(
      config(style_guide_class)
    )
  end

  def style_guide_class(filename)
    case filename
    when /.+\.rb\z/
      StyleGuide::Ruby
    when /.+\.coffee(\.js)?\z/
      StyleGuide::CoffeeScript
    when /.+\.js\z/
      StyleGuide::JavaScript
    when /.+\.scss\z/
      StyleGuide::Scss
    else
      StyleGuide::Unsupported
    end
  end

  def config(style_guide_class)
    pull_request.file_content(style_guide_class::CONFIG_FILE)
  end
end
