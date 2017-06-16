class JsIgnore
  DEFAULT_EXCLUDED_PATHS = %w(
    vendor/**/*
    node_modules/**/*
    bower_components/**/*
  ).freeze

  attr_private_initialize :linter_name, :hound_config, :default_filename

  def file_included?(filename)
    !pathspec.match(filename)
  end

  private

  def pathspec
    @_pathspec ||= PathSpec.new(excluded_paths)
  end

  def excluded_paths
    DEFAULT_EXCLUDED_PATHS + ignored_paths
  end

  def ignored_paths
    @ignored_paths ||= hound_config.
      commit.
      file_content(ignore_filename).
      to_s.
      split("\n")
  end

  def ignore_filename
    @ignore_filename ||= hound_config.
      content.
      fetch(linter_name, {}).
      fetch("ignore_file", default_filename)
  end
end
