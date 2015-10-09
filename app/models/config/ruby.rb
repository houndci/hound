module Config
  class Ruby < Base
    def content
      if legacy?
        hound_config.content
      else
        super
      end
    end

    private

    def parse(file_content)
      result = Parser.yaml(file_content)

      ensure_correct_type(result)
    end

    def legacy?
      (configured_languages & HoundConfig::LANGUAGES).empty?
    end

    def configured_languages
      hound_config.content.keys
    end
  end
end
