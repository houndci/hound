# frozen_string_literal: true

class EmptyCommit < Commit
  def initialize
  end

  def file_content(_filename)
    ""
  end
end
