module Config
  class Python < Base
    def content
      @content ||= owner_config.deep_merge(super.presence || default_content)
    end

    def serialize(data = content)
      Serializer.ini(data)
    end

    private

    def parse(file_content)
      Parser.ini(file_content)
    end

    def default_content
      {}
    end
  end
end
