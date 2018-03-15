# frozen_string_literal: true

module Linter
  class Reek < Base
    FILE_REGEXP = /.+\.r(b|ake)\z/
  end

  private

  def serialized_configuration
    "--- {}\n"
  end
end
