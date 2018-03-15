# frozen_string_literal: true

require "app/services/sanitize_ini_file"

RSpec.describe SanitizeIniFile do
  describe ".call" do
    it "returns config with trailing slashes" do
      config = <<~EOS
        [flake8]
        max-line-length = 80 # to support multiple splits
        ignore =
          # multiple spaces before operator
          E221,
          # multiple spaces after operator
          E222,
          # missing whitespace around operator
          E225
        max-complexity = 10
      EOS

      result = SanitizeIniFile.call(config)

      expect(result).to eq <<~EOS
        [flake8]
        max-line-length = 80
        ignore = E221,E222,E225
        max-complexity = 10
      EOS
    end
  end
end
