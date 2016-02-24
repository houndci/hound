module Linter
  class Eslint < Base
    FILE_REGEXP = /.+(\.js|\.es6|\.es6\.js|\.jsx)\z/
  end
end
