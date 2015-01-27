module StyleGuide
  class JavaScript < Base
    CUSTOM_CONFIG_FILE = ".javascript-style.json"

    def violations_in_file(file)
      Jshintrb.lint(file.content, config).compact.map do |violation|
        line = file.line_at(violation["line"])

        Violation.new(
          filename: file.filename,
          patch_position: line.patch_position,
          line: line,
          line_number: violation["line"],
          messages: [violation["reason"]]
        )
      end
    end

    private

    def config
      if File.file?(CUSTOM_CONFIG_FILE)
        JSON.parse(File.read(CUSTOM_CONFIG_FILE))
      else
        Hash.new
      end
    end
  end
end
