# Patch SCSSLint::Config to expand file_path
# to the same directory as the config file,
# which is a Tempfile itself.
module SCSSLint
  class Config
    def excluded_file?(file_path)
      config_file_tmp_dir = Dir.tmpdir
      abs_path = File.expand_path(file_path, config_file_tmp_dir)

      @options.fetch("exclude", []).any? do |exclusion_glob|
        File.fnmatch(exclusion_glob, abs_path)
      end
    end
  end
end
