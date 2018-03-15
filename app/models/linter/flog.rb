# frozen_string_literal: true

module Linter
  class Flog < Base
    FILE_REGEXP = /.+\.r(b|ake)\z/

    private

    def serialized_configuration
      "--- {}\n"
    end
  end
end
