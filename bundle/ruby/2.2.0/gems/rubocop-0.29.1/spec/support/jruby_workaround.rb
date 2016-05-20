# encoding: utf-8

# Force JRuby not to select the current working directory
# as a temporary directory on Travis CI.
# https://github.com/jruby/jruby/issues/405
if ENV['TRAVIS'] && RUBY_ENGINE == 'jruby'
  require 'fileutils'

  tmp_dir = ENV['TMPDIR'] || ENV['TMP'] || ENV['TEMP'] ||
            Etc.systmpdir || '/tmp'

  non_world_writable_tmp_dir = File.join(tmp_dir, 'rubocop')
  FileUtils.makedirs(non_world_writable_tmp_dir, mode: 0700)
  ENV['TMPDIR'] = non_world_writable_tmp_dir
end
