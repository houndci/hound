require 'rainbow/global'
require 'rainbow/legacy'

module Rainbow

  def self.new
    Wrapper.new(global.enabled)
  end

  self.enabled = false unless STDOUT.tty? && STDERR.tty?
  self.enabled = false if ENV['TERM'] == 'dumb'
  self.enabled = true if ENV['CLICOLOR_FORCE'] == '1'

  # On Windows systems, try to load the local ANSI support library
  require 'rbconfig'
  if RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
    begin
      require 'Win32/Console/ANSI'
    rescue LoadError
      self.enabled = false
    end
  end

end
