module Config
  class Base
    pattr_initialize :hound_config, :linter_name

    def content
      @content ||= parse(load_content)
    rescue JSON::ParserError, Psych::Exception => exception
      raise_parse_error(exception.message)
    end

    def excluded_files
      []
    end

    private

    DEFAULT_CONTENT = "{}"

    attr_implement :parse, [:file_content]

    def ensure_correct_type(result)
      if result.is_a? Hash
        result
      else
        raise_type_error
      end
    end

    def raise_type_error
      raise_parse_error("`#{file_path}` must be a Hash")
    end

    def load_content
      if file_path
        if url?
          fetch_url
        else
          commit.file_content(file_path)
        end
      else
        DEFAULT_CONTENT
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

    def raise_parse_error(message)
      raise Config::ParserError.new(message, filename: file_path)
    end

    def file_path
      linter_config["config_file"]
    end

    def linter_config
      hound_config.content[linter_name]
    end

    def commit
      hound_config.commit
    end
  end
end
