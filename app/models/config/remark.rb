# frozen_string_literal: true

module Config
  class Remark < Base
    def serialize(data = content)
      Serializer.json(data)
    end
  end
end
