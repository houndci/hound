module Config
  class Mdast < Base
    private

    def parse(file_content)
      Parser.raw(file_content)
    end
  end
end
