module Config
  class Scss < Base
    private

    def parse(file_content)
      Parser.raw(file_content)
    end
  end
end
