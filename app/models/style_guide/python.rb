module StyleGuide
  class Python < Base
    DEFAULT_CONFIG_FILENAME = "python.json"

    def lint(file, config = {})
      opts = config.to_a.map{ |key, value| "--#{key} #{value}" }.join(" ")
      lines = `echo "#{file.content}" | flake8 - #{opts}`.split("\n")
      lines.map do |line|
        parts = line.split(":")
        {
          'file' => parts[0],
          'line' => parts[1].to_i,
          'char' => parts[2].to_i,
          'msg' => parts[3].strip
        }
      end
    end

    def violations_in_file(file)
      lint(file, config).map do |violation|
        line = file.line_at(violation["line"])

        Violation.new(
          filename: file.filename,
          line: line,
          patch_position: line.patch_position,
          line_number: violation["line"],
          messages: [violation["msg"]]
        )
      end
    end

    private

    def config
      default_config.merge(repo_config.for(name))
    end

    def default_config
      config = File.read(default_config_file)
      JSON.parse(config)
    end

    def default_config_file
      DefaultConfigFile.new(
        DEFAULT_CONFIG_FILENAME,
        repository_owner_name
      ).path
    end
  end
end
