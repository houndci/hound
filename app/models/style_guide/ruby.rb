module StyleGuide
  class Ruby < Base
    BASE_CONFIG_FILE = "config/style_guides/ruby.yml"
    CONFIG_FILE = ".ruby-style.yml"

    attr_reader :custom_config

    def initialize(config = "")
      config = YAML.load(config) || {}
      @custom_config = RuboCop::Config.new(config, CONFIG_FILE)
      @custom_config.add_missing_namespaces
      @custom_config.make_excludes_absolute
    end

    def violations_in_file(file)
      if config.file_to_exclude?(file.filename)
        []
      else
        # Are non ".rb" riles having a chance to get here?
        rubocop_team.inspect_file(processed_source(file)).map do |violation|
          line = file.line_at(violation.line)

          Violation.new(
            filename: file.filename,
            patch_position: line.patch_position,
            line: line,
            line_number: violation.line,
            messages: [violation.message]
          )
        end
      end
    end

    private

    def rubocop_team
      RuboCop::Cop::Team.new(RuboCop::Cop::Cop.all, config)
    end

    def processed_source(file)
      RuboCop::ProcessedSource.new(file.content, file.filename)
    end

    def config
      @config ||= RuboCopConfig.new(merged_config, "")
    end

    def merged_config
      RuboCop::ConfigLoader.merge(base_config, custom_config)
    end

    def base_config
      RuboCop::ConfigLoader.load_file(BASE_CONFIG_FILE)
    end
  end
end
