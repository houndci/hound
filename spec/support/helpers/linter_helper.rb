module LinterHelper
  def build_linter(
    build = build(:build, repo: build_repo_without_owner_config),
    extra_files = {}
  )
    head_commit = double("Commit", file_content: "{}")
    stub_commit_to_return_hound_config(head_commit)
    stub_commit_to_return_extra_files(head_commit, extra_files)
    described_class.new(
      hound_config: HoundConfig.new(head_commit),
      build: build,
      repository_owner_name: "ralph",
    )
  end

  def build_repo_without_owner_config
    build(:repo, owner: build(:owner, config_enabled: false))
  end

  def raw_hound_config
    <<-EOS.strip_heredoc
      ruby:
        enabled: true
        config_file: config/rubocop.yml

      coffeescript:
        enabled: true
        config_file: coffeelint.json

      javascript:
        enabled: true
        config_file: config/javascript.json

      scss:
        enabled: true
        config_file: config/scss.yml

      haml:
        enabled: true
        config_file: config/haml.json

      go:
        enabled: true
        config_file: config/go.txt

      swift:
        enabled: true
        config_file: config/swift.txt
    EOS
  end

  def stub_commit_to_return_hound_config(commit)
    allow(commit).to receive(:file_content).with(HoundConfig::CONFIG_FILE).
      and_return(raw_hound_config)
  end

  def stub_commit_to_return_extra_files(commit, configuration)
    configuration.each do |filename, contents|
      allow(commit).to receive(:file_content).with(filename).
        and_return(contents)
    end
  end

  def stubbed_commit(configuration)
    commit = double("Commit")

    configuration.each do |filename, contents|
      allow(commit).to receive(:file_content).with(filename).
        and_return(contents)
    end

    commit
  end
end

RSpec.configure do |config|
  config.include LinterHelper
end
