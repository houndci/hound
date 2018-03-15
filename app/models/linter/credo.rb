# frozen_string_literal: true

module Linter
  class Credo < Base
    FILE_REGEXP = /.+(\.ex|\.exs)\z/
  end
end
