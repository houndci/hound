module Config
  class Base
    def initialize(hound_config, owner: MissingOwner.new)
      @hound_config = hound_config
      @owner = owner
    end

    def content
      @content ||= owner_config.deep_merge(load)
    rescue ConfigContent::ContentError => exception
      raise_parse_error(exception.message)
    rescue Config::ParserError
      raise_parse_error("#{file_path} format is invalid")
    end

    def serialize
      raise NotImplementedError, "implement ##{method} in your config class"
    end

    def linter_name
      self.class.name.demodulize.underscore
    end

    private

    attr_reader :hound_config, :owner

    def load
      ConfigContent.new(
        commit: commit,
        file_path: file_path,
        parser: ->(content) { parse(content) },
      ).load
    end

    def owner_config
      owner.config_content(linter_name)
    end

    def parse(content)
      Parser.yaml(content)
    end

    def raise_parse_error(message)
      raise Config::ParserError, message
    end

    def file_path
      linter_config && linter_config["config_file"]
    end

    def linter_config
      hound_config.content.slice(linter_name).values.first
    end

    def commit
      hound_config.commit
    end
  end
end
