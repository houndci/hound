module Config
  class Python < Base
    private

    def parse(file_content)
      Parser.raw(file_content)
    end
  end
end
