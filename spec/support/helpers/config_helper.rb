# frozen_string_literal: true

module ConfigHelper
  def stub_commit(configuration)
    commit = instance_double("Commit")

    configuration.each do |filename, contents|
      allow(commit).to receive(:file_content).with(filename).
        and_return(contents)
    end

    commit
  end

  def build_config(content, owner = MissingOwner.new)
    config_filename = "config/linter-config.any"
    commit = stub_commit(config_filename => content)
    hound_config = build_hound_config(commit, config_filename)

    described_class.new(hound_config, owner: owner)
  end

  def build_hound_config(commit, config_filename)
    content = {
      described_class.name.demodulize.underscore => {
        "enabled": true,
        "config_file" => config_filename,
      },
    }
    instance_double("HoundConfig", commit: commit, content: content)
  end
end

RSpec.configure do |config|
  config.include ConfigHelper
end
