module Config
  class Credo < Base
    def content
      @content ||= load_content
    end

    def default_content
      ""
    end

    private

    def load_content
      if file_path
        commit.file_content(file_path)
      else
        default_content
      end
    end
  end
end
