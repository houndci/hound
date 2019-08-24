module Linter
  class Eslint < Base
    FILE_REGEXP = /.+(\.js|\.es6|\.jsx|\.vue|\.ts|\.tsx)\z/
    IGNORE_FILENAME = ".eslintignore".freeze

    def file_included?(commit_file)
      ignore_file.file_included?(commit_file.filename)
    end

    private

    def ignore_file
      @_ignore_file ||= IgnoreFile.new(name, hound_config, IGNORE_FILENAME)
    end
  end
end
