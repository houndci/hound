# frozen_string_literal: true

class LinterVersion
  LINTERS_REPO_NAME = "houndci/linters"
  LOCKFILE_TO_LINTERS = {
    gemfile: %i(
      flog
      haml_lint
      reek
      rubocop
      scss_lint
      slim_lint
    ),
    yarn: %i(
      coffeelint
      eslint
      jshint
      sass-lint
      stylelint
      tslint
    ),
  }.freeze

  def self.all
    new.all
  end

  def all
    LOCKFILE_TO_LINTERS.flat_map do |lockfile, linters|
      linters.map do |linter|
        [linter, send("version_from_#{lockfile}", linter)]
      end
    end.to_h
  end

  private

  def version_from_gemfile(linter_name)
    gemfile_content.
      scan(/^ {4}#{linter_name} \((.*)\)/).
      flatten.first || "N/A"
  end

  def version_from_yarn(linter_name)
    yarn_content.
      scan(/^#{linter_name}@(?:[^\n]+)\s+version\s"([\d\.]+)/).
      flatten.
      map { |version| Gem::Version.new(version) }.
      max&.version || "N/A"
  end

  def gemfile_content
    @_gemfile_content ||= file_content("Gemfile.lock")
  end

  def yarn_content
    @_yarn_content ||= file_content("yarn.lock")
  end

  def file_content(file_name)
    file = client.file_contents(LINTERS_REPO_NAME, file_name, "master")
    if file&.content
      Base64.decode64(file.content).force_encoding("UTF-8")
    else
      ""
    end
  end

  def client
    @_client ||= GitHubApi.new(Hound::GITHUB_TOKEN)
  end
end
