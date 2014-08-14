# Filters files to reviewable subset.
# Builds style guide based on file extension.
# Delegates to style guide for line violations.
class StyleChecker
  def initialize(modified_files, custom_config = nil)
    @modified_files = modified_files
    @custom_config = custom_config || "{}"
  end

  def violations
    @violations ||= unremoved_files.map do |file|
      style_guide(file.filename).violations(file)
    end.flatten
  end

  private

  def unremoved_files
    @modified_files.reject { |file| file.removed? }
  end

  def style_guide(filename)
    style_guide_builder(filename).new(@custom_config)
  end

  def style_guide_builder(filename)
    case filename
    when /.*\.rb$/
      @ruby_style_guide ||= StyleGuide::Ruby
    else
      @null_style_guide ||= StyleGuide::Null
    end
  end
end
