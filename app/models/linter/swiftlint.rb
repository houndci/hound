module Linter
  class Swiftlint < Base
    FILE_REGEXP = /.+\.swift\z/

    def file_included?(commit_file)
      !pathspec.match(commit_file.filename)
    end

    private

    def pathspec
      @_pathspec ||= PathSpec.new(config.content["excluded"])
    end
  end
end
