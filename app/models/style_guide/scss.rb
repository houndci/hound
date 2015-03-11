module StyleGuide
  class Scss
    class ScssWorker < ActiveJob::Base
      queue_as :scss
    end

    DEFAULT_CONFIG_FILENAME = "scss.yml"

    def violations_in_file(file)
      # find build later by sha
      # find pending violation later through build and by filename
      Worker.perform_later(
        repo_name: file.repo_name,
        filename: file.filename,
        commit: file.sha,
        patch: file.patch_body,
        content: file.content,
        default_config: default_config,
        custom_config: custom_config
      )

      pending_violation = Violation.new(
        pending: true,
        filename: file.filename
      )
      [pending_violation]
    end

    private

    def default_config
      DefaultConfigFile.new(
        DEFAULT_CONFIG_FILENAME,
        repository_owner_name
      ).path
    end

    def custom_config
      repo_config.for(name)
    end
  end
end
