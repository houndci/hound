module Config
  class Tslint < Base
    def initialize(hound_config, owner: nil)
      super(hound_config)
      @owner = owner
    end

    def content
      owner_config_content.deep_merge(super)
    end

    def serialize(data = content)
      Serializer.json(data)
    end

    private

    def parse(file_content)
      json_with_comments = JsonWithComments.new(file_content)
      content_without_comments = json_with_comments.without_comments
      Parser.yaml(content_without_comments)
    end

    def owner_config_content
      if @owner.present?
        Config::TsLint.new(owner_hound_config).content
      else
        {}
      end
    end

    def owner_hound_config
      BuildOwnerHoundConfig.run(@owner)
    end
  end
end
