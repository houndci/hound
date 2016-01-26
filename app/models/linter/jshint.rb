module Linter
  class Jshint < Base
    FILE_REGEXP = /.+\.js\z/

    def file_included?(commit_file)
      config.excluded_files.none? do |pattern|
        File.fnmatch?(pattern, commit_file.filename)
      end
    end
  end
end
