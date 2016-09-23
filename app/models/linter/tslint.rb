module Linter
  class Tslint < Base
    FILE_REGEXP = /.+\.ts\z/
  end

  private

  def config
    Config::TsLint.new(hound_config, owner: build.repo.owner)
  end
end
