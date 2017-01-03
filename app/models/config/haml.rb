module Config
  class Haml < Base
    def initialize(hound_config, owner: MissingOwner.new)
      super(hound_config)
      @owner = owner
    end

    def content
      owner_config.deep_merge(super)
    end

    def serialize(data = content)
      Serializer.yaml(data)
    end

    private

    attr_reader :owner

    def owner_config
      owner.hound_config
    end

    def parse(file_content)
      Parser.yaml(file_content)
    end
  end
end
