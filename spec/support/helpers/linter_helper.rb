module LinterHelper
  def build_linter(build = build(:build))
    head_commit = double("Commit", file_content: "{}")
    stub_commit_to_return_hound_config(head_commit)
    described_class.new(
      hound_config: HoundConfig.new(head_commit),
      build: build,
      repository_owner_name: "ralph",
    )
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
