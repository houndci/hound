# Collection of exceptions that can be raised by the HAML Lint application.
module HamlLint::Exceptions
  # Raised when a {Configuration} could not be loaded from a file.
  class ConfigurationError < StandardError; end

  # Raised when invalid/incompatible command line options are provided.
  class InvalidCLIOption < StandardError; end

  # Raised when an invalid file path is specified
  class InvalidFilePath < StandardError; end

  # Raised when a problem occurs parsing a HAML document.
  class ParseError < ::Haml::SyntaxError; end

  # Raised when attempting to execute `Runner` with options that would result in
  # no linters being enabled.
  class NoLintersError < StandardError; end
end
