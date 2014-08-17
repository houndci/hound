# Filters files to reviewable subset.
# Builds style guide based on file extension.
# Delegates to style guide for line violations.
class StyleChecker
  def initialize(pull_request)
    @pull_request = pull_request
  end

  def violations
    @violations ||= unremoved_files.map do |file|
      style_guide(file.filename).violations(file)
    end.flatten
  end

  private

  def unremoved_files
    @pull_request.pull_request_files.reject { |file| file.removed? }
  end

  def style_guide(filename)
    case filename
    when /.*\.rb$/
      @ruby_style_guide ||= StyleGuide::Ruby.new(@pull_request)
    when /.*\.coffee.?/
      @coffee_script_style_guide ||= StyleGuide::CoffeeScript.new(@pull_request)
    else
      @null_style_guide ||= StyleGuide::Null.new(@pull_request)
    end
  end
end
