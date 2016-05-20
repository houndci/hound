module Octokit
  # Current major release.
  # @return [Integer]
  MAJOR = 4

  # Current minor release.
  # @return [Integer]
  MINOR = 1

  # Current patch level.
  # @return [Integer]
  PATCH = 1

  # Full release version.
  # @return [String]
  VERSION = [MAJOR, MINOR, PATCH].join('.').freeze
end
