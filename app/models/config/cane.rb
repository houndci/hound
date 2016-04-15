module Config
  class Cane < Base
    private

    def ensure_correct_type(config)
      # Short circuiting this method for now since
      # the config probably shouldn't be parsed by Hound
      config
    end

    def parse(file_content)
      file_content.split(/\s+/m)
    end
  end
end
