module Config
  class Eslint < Base
    def initialize(hound_config, owner: MissingOwner.new)
      super(hound_config)
      @owner = owner
    end

    def content
      owner_config.deep_merge(super)
    end

    def serialize(data = content)
      Serializer.json(data)
    end

    private

    attr_reader :owner

    def owner_config
      owner.hound_config
    end

    def parse(file_content)
      json_with_comments = JsonWithComments.new(file_content)
      content_without_comments = json_with_comments.without_comments
      Parser.yaml(content_without_comments)
    end
  end
end
