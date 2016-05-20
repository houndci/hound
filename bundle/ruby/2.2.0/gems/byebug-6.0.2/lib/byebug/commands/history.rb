require 'byebug/command'
require 'byebug/helpers/parse'

module Byebug
  #
  # Show history of byebug commands.
  #
  class HistoryCommand < Command
    include Helpers::ParseHelper

    self.allow_in_post_mortem = true

    def self.regexp
      /^\s* hist(?:ory)? (?:\s+(?<num_cmds>.+))? \s*$/x
    end

    def self.description
      <<-EOD
        hist[ory] [num_cmds]

        #{short_description}
      EOD
    end

    def self.short_description
      "Shows byebug's history of commands"
    end

    def execute
      history = processor.interface.history

      if @match[:num_cmds]
        size, err = get_int(@match[:num_cmds], 'history', 1, history.size)
        return errmsg(err) unless size
      end

      puts history.to_s(size)
    end
  end
end
