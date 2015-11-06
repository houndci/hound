module Linter
  class Eslint < Base
    FILE_REGEXP = /.+(\.js|\.es6|\.es6\.js)\z/
  end
end
