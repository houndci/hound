module Config
  class CoffeeScript < Base
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
      Parser.json(file_content)
    end

    def owner_config_content
      if @owner.present?
        Config::CoffeeScript.new(owner_hound_config).content
      else
        {}
      end
    end

    def owner_hound_config
      BuildOwnerHoundConfig.run(@owner)
    end
  end
end
