# frozen_string_literal: true

module Config
  class SassLint < Base
    def serialize(data = content)
      Serializer.yaml(data)
    end
  end
end
