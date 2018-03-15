# frozen_string_literal: true

module Config
  class CoffeeScript < Base
    def serialize(data = content)
      Serializer.json(data)
    end

    private

    def parse(file_content)
      json_with_comments = JsonWithComments.new(file_content)
      content_without_comments = json_with_comments.without_comments
      super(content_without_comments)
    end
  end
end
