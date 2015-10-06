module HamlLint
  # A miscellaneous set of utility functions.
  module Utils
    module_function

    # Returns whether a glob pattern (or any of a list of patterns) matches the
    # specified file.
    #
    # This is defined here so our file globbing options are consistent
    # everywhere we perform globbing.
    #
    # @param glob [String, Array]
    # @param file [String]
    # @return [Boolean]
    def any_glob_matches?(globs_or_glob, file)
      Array(globs_or_glob).any? do |glob|
        ::File.fnmatch?(glob, file,
                        ::File::FNM_PATHNAME | # Wildcards don't match path separators
                        ::File::FNM_DOTMATCH)  # `*` wildcard matches dotfiles
      end
    end

    # Yields interpolated values within a block of text.
    #
    # @param text [String]
    # @yield Passes interpolated code and line number that code appears on in
    #   the text.
    # @yieldparam interpolated_code [String] code that was interpolated
    # @yieldparam line [Integer] line number code appears on in text
    def extract_interpolated_values(text) # rubocop:disable Metrics/AbcSize
      dumped_text = text.dump
      newline_positions = extract_substring_positions(dumped_text, '\\\n')

      Haml::Util.handle_interpolation(dumped_text) do |scan|
        line = (newline_positions.find_index { |marker| scan.pos <= marker } ||
                newline_positions.size) + 1

        escape_count = (scan[2].size - 1) / 2
        break unless escape_count.even?

        dumped_interpolated_str = Haml::Util.balance(scan, '{', '}', 1)[0][0...-1]

        # Hacky way to turn a dumped string back into a regular string
        yield [eval('"' + dumped_interpolated_str + '"'), line] # rubocop:disable Eval
      end
    end

    # Returns indexes of all occurrences of a substring within a string.
    #
    # Note, this will not return overlaping substrings, so searching for "aa"
    # in "aaa" will only find one substring, not two.
    #
    # @param text [String] the text to search
    # @param substr [String] the substring to search for
    # @return [Array<Integer>] list of indexes where the substring occurs
    def extract_substring_positions(text, substr)
      positions = []
      scanner = StringScanner.new(text)
      positions << scanner.pos while scanner.scan(/(.*?)#{substr}/)
      positions
    end

    # Converts a string containing underscores/hyphens/spaces into CamelCase.
    #
    # @param str [String]
    # @return [String]
    def camel_case(str)
      str.split(/_|-| /).map { |part| part.sub(/^\w/, &:upcase) }.join
    end

    # Find all consecutive items satisfying the given block of a minimum size,
    # yielding each group of consecutive items to the provided block.
    #
    # @param items [Array]
    # @param satisfies [Proc] function that takes an item and returns true/false
    # @param min_consecutive [Fixnum] minimum number of consecutive items before
    #   yielding the group
    # @yield Passes list of consecutive items all matching the criteria defined
    #   by the `satisfies` {Proc} to the provided block
    # @yieldparam group [Array] List of consecutive items
    # @yieldreturn [Boolean] block should return whether item matches criteria
    #   for inclusion
    def for_consecutive_items(items, satisfies, min_consecutive = 2)
      current_index = -1

      while (current_index += 1) < items.count
        next unless satisfies[items[current_index]]

        count = count_consecutive(items, current_index, &satisfies)
        next unless count >= min_consecutive

        # Yield the chunk of consecutive items
        yield items[current_index...(current_index + count)]

        current_index += count # Skip this patch of consecutive items to find more
      end
    end

    # Count the number of consecutive items satisfying the given {Proc}.
    #
    # @param items [Array]
    # @param offset [Fixnum] index to start searching from
    # @yield [item] Passes item to the provided block.
    # @yieldparam item [Object] Item to evaluate as matching criteria for
    #   inclusion
    # @yieldreturn [Boolean] whether to include the item
    # @return [Integer]
    def count_consecutive(items, offset = 0, &block)
      count = 1
      count += 1 while (offset + count < items.count) && block.call(items[offset + count])
      count
    end

    # Calls a block of code with a modified set of environment variables,
    # restoring them once the code has executed.
    #
    # @param env [Hash] environment variables to set
    def with_environment(env)
      old_env = {}
      env.each do |var, value|
        old_env[var] = ENV[var.to_s]
        ENV[var.to_s] = value
      end

      yield
    ensure
      old_env.each { |var, value| ENV[var.to_s] = value }
    end
  end
end
