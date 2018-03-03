# frozen_string_literal: true

module Linter
  class Jshint < Base
    FILE_REGEXP = /.+\.js\z/
    IGNORE_FILENAME = ".jshintignore".freeze

    def file_included?(commit_file)
      ignore_file.file_included?(commit_file.filename)
    end

    private

    def ignore_file
      @_ignore_file ||= IgnoreFile.new(name, hound_config, IGNORE_FILENAME)
    end
  end
end
