module StyleGuide
  class Scss < Base
    DEFAULT_CONFIG_FILENAME = "scss.yml"

    def violations_in_file(file)
      default_config = File.read(default_config_file)
      custom_config = File.read(repo_config.config_for(name)

      ScssReviewJob.perform_later(
        repo_name: file.repo_name,
        filename: file.filename,
        commit: file.sha,
        patch: file.patch_body,
        content: file.content,
        default_config: default_config,
        custom_config: custom_config
      )

      [Violation.new(pending: true, filename: file.filename)]
    end

    private

    def default_config_file
      DefaultConfigFile.new(
        DEFAULT_CONFIG_FILENAME,
        repository_owner_name
      ).path
    end
  end
end
