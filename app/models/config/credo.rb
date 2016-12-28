module Config
  class Credo < Base
    def content
      @content ||= load_content
    end

    def default_content
      ""
    end
  end
end
