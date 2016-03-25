module Config
  class Eslint < Base
    def serialize(_data = nil)
      Serializer.json(
        raw_content: load_content,
        file_name: file_path,
        hound_config_eslint_version: 2
      )
    end

    private

    def parse(file_content)
      raise "Please don't parse me"
    end
  end
end
