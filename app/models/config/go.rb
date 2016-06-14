module Config
  class Go < Base
    DEFAULT_CONFIG = ""

    def content
      DEFAULT_CONFIG
    end

    def merge(_config)
      DEFAULT_CONFIG
    end
  end
end
