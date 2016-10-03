module Linter
  class Eslint < Base
    FILE_REGEXP = /.+(\.js|\.es6|\.jsx)\z/
    IGNORE_FILENAME = ".eslintignore".freeze

    delegate :file_included?, to: :jsignore

    private

    def jsignore
      @jsignore ||= JsIgnore.new(name, hound_config, IGNORE_FILENAME)
    end
  end
end
