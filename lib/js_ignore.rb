class JsIgnore
  DEFAULT_EXCLUDED_PATHS = %w(vendor/*).freeze

  def initialize(hound_config, ignore_filename)
    @hound_config = hound_config
    @ignore_filename = ignore_filename
  end

  def file_included?(commit_file)
    excluded_paths.none? do |pattern|
      File.fnmatch?(pattern, commit_file.filename)
    end
  end

  private

  def excluded_paths
    ignored_paths.presence || DEFAULT_EXCLUDED_PATHS
  end

  def ignored_paths
    @hound_config.commit.file_content(ignore_filename).to_s.split("\n")
  end

  def ignore_filename
    # Check the hound config for an ignore file
    @hound_config.
      content.
      fetch("javascript", {}).
      fetch("ignore_file", @ignore_filename)
  end
end
