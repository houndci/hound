class JshintConfigBuilder
  static_facade :call
  pattr_initialize :hound_config

  def call
    Config::Jshint.new(load_content)
  end

  private

  def load_content
    if file_path
      if url?
        fetch_url
      else
        commit.file_content(file_path)
      end
    else
      "{}"
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

  def file_path
    linter_config && linter_config["config_file"]
  end

  def linter_config
    hound_config.content.slice("jshint").values.first
  end

  def commit
    hound_config.commit
  end
end
