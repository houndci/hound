# Filters files to reviewable subset.
# Builds style guide based on file extension.
# Delegates to style guide for line violations.
class StyleChecker
  pattr_initialize :pull_request

  def violations
    @violations ||= files_with_changes.flat_map do |file|
      style_guide(file.filename).violations(file)
    end
  end

  private

  def files_with_changes
    pull_request.pull_request_files.reject(&:removed?)
  end

  def style_guide(filename)
    if filename =~ /.*\.rb$/
      @ruby_style_guide ||= StyleGuide::Ruby.new(config)
    elsif filename =~ /.*\.coffee.?/ && enabled?("CoffeeScript")
      @coffee_script_style_guide ||= StyleGuide::CoffeeScript.new
    else
      @unsupported_style_guide ||= StyleGuide::Unsupported.new
    end
  end

  def enabled?(language)
    config[language] && config[language]["Enabled"] == true
  end

  def config
    CommitConfig.new(pull_request.head_commit).to_hash
  end
end
