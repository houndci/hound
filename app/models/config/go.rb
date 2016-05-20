module Config
  class Go < Base
    DEFAULT_CONFIG = ""

    def linter_names
      [
        "golint",
        linter_name,
      ]
    end

    def content
      DEFAULT_CONFIG
    end
  end
end
