# frozen_string_literal: true
module Linter
  class Stylelint < Base
    FILE_REGEXP = /.+(\.scss|\.css|\.less)\z/
    IGNORE_FILENAME = ".stylelintignore"

    def file_included?(commit_file)
      ignore_file.file_included?(commit_file.filename)
    end

    private

    def ignore_file
      @_ignore_file ||= IgnoreFile.new(name, hound_config, IGNORE_FILENAME)
    end
  end
end
