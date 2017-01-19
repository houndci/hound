module Config
  class Credo < Base
    def content
      @content ||= load_content
    end

    private

    def load_content
      if file_path
        commit.file_content(file_path)
      else
        ""
      end
    end
  end
end
