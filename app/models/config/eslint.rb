module Config
  class Eslint < Base
    def serialize
      Serializer.json(content)
    end

    private

    def parse(file_content)
      json_with_comments = JsonWithComments.new(file_content)
      content_without_comments = json_with_comments.without_comments
      super(content_without_comments)
    end
  end
end
