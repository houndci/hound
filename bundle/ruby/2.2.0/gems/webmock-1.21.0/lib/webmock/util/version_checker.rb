# This code was created based on https://github.com/myronmarston/vcr/blob/master/lib/vcr/util/version_checker.rb
# Thanks to @myronmarston

# Copyright (c) 2010-2012 Myron Marston

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module WebMock
  class VersionChecker
    def initialize(library_name, library_version, min_patch_level, max_minor_version = nil)
      @library_name, @library_version = library_name, library_version
      @min_patch_level, @max_minor_version = min_patch_level, max_minor_version

      @major,     @minor,     @patch     = parse_version(library_version)
      @min_major, @min_minor, @min_patch = parse_version(min_patch_level)
      @max_major, @max_minor             = parse_version(max_minor_version) if max_minor_version

      @comparison_result = compare_version
    end

    def check_version!
      warn_about_too_low if too_low?
      warn_about_too_high if too_high?
    end

  private

    def too_low?
      @comparison_result == :too_low
    end

    def too_high?
      @comparison_result == :too_high
    end

    def warn_about_too_low
      warn_in_red "You are using #{@library_name} #{@library_version}. " +
                  "WebMock supports version #{version_requirement}."
    end

    def warn_about_too_high
      warn_in_red "You are using #{@library_name} #{@library_version}. " +
                  "WebMock is known to work with #{@library_name} #{version_requirement}. " +
                  "It may not work with this version."
    end

    def warn_in_red(text)
      Kernel.warn colorize(text, "\e[31m")
    end

    def compare_version
      case
        when @major < @min_major then :too_low
        when @max_major && @major > @max_major then :too_high
        when @major > @min_major then :ok
        when @minor < @min_minor then :too_low
        when @max_minor && @minor > @max_minor then :too_high
        when @minor > @min_minor then :ok
        when @patch < @min_patch then :too_low
      end
    end

    def version_requirement
      req = ">= #{@min_patch_level}"
      req += ", < #{@max_major}.#{@max_minor + 1}" if @max_minor
      req
    end

    def parse_version(version)
      version.split('.').map { |v| v.to_i }
    end

    def colorize(text, color_code)
      "#{color_code}#{text}\e[0m"
    end
  end
end
