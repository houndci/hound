# frozen_string_literal: true

module Linter
  class Coffeelint < Base
    FILE_REGEXP = /.+\.coffee(\.js)?(\.erb)?\z/
  end
end
