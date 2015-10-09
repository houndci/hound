module Config
  class Haml < Base
    private

    def parse(file_content)
      result = Parser.yaml(file_content)

      ensure_correct_type(result)
    end
  end
end
