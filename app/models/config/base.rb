module Config
  class Base
    attr_reader_initialize :hound_config

    def content
      @content ||= ensure_correct_type(safe_parse(load_content))
    end

    def excluded_files
      []
    end

    def serialize(data = content)
      data
    end

    def linter_name
      self.class.name.demodulize.underscore
    end

    private

    attr_implement :parse, [:file_content]

    def safe_parse(content)
      parse(content)
    rescue JSON::ParserError, Psych::Exception => exception
      raise_parse_error(exception.message)
    end

    def ensure_correct_type(config)
      if config.is_a? Hash
        config
      else
        raise_type_error
      end
    end

    def raise_type_error
      raise_parse_error(%{"#{file_path}" must be a Hash})
    end

    def load_content
      if file_path
        if url?
          fetch_url
        else
          commit.file_content(file_path)
        end
      else
        default_content
      end
    end

    def fetch_url
      response = Faraday.new.get(file_path)

      if response.success?
        response.body
      else
        raise_parse_error("#{response.status} #{response.body}")
      end
    end

    def url?
      URI::regexp(%w(http https)).match(file_path)
    end

    def default_content
      "{}"
    end

    def raise_parse_error(message)
      raise Config::ParserError.new(message, linter_name: linter_name)
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
