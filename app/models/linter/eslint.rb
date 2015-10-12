module Linter
  class Eslint < Base
    FILE_REGEXP = /.+((?<!\.coffee)\.js|(?:\.es6|\.es6\.js))\z/
  end
end
