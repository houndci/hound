# only applies when used as a plugin
case Rails::VERSION::MAJOR
when 2
  require 'rails_stdout_logging/rails2'
  RailsStdoutLogging::Rails2.set_logger
when 3
  require 'rails_stdout_logging/rails3'
  RailsStdoutLogging::Rails3.set_logger
end
